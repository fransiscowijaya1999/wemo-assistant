import { Hono } from 'hono';
import { and, eq, inArray, isNull, or } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import type { Db } from '../db/client';
import {
  assemblies,
  assemblyItems,
  itemResolutions,
  machines,
  machineVariants,
  partColorVariants,
  partNumbers,
  partSubstitutes,
  parts,
} from '../db/schema';
import { searchParts } from '../ai/catalog-tools';
import { requireAdmin } from '../middleware/auth';

export const partsRoute = new Hono<{ Bindings: Bindings }>();

// Fuzzy candidate search: partial part numbers (with or without dashes), names,
// aliases — token-scored, best first. Same engine as the assistant's search tool.
// Registered before '/:id' so 'search' is not captured as an id.
partsRoute.get('/search', async (c) => {
  const q = c.req.query('q');
  if (!q?.trim()) return c.json({ error: 'q query param is required' }, 400);
  const results = await searchParts(getDb(c.env), q);
  return c.json({ results });
});

async function getPartFull(db: Db, id: string) {
  const part = await db.select().from(parts).where(eq(parts.id, id)).get();
  if (!part) return null;
  const numbers = await db.select().from(partNumbers).where(eq(partNumbers.partId, id));
  const colorVariants = await db.select().from(partColorVariants).where(eq(partColorVariants.partId, id));
  const placements = await getPlacements(db, numbers.map((n) => ({ id: n.id, value: n.value })));
  const substitutes = await getSubstitutes(db, id);
  return { ...part, numbers, colorVariants, placements, substitutes };
}

// The parts this one is manually linked to as a substitute (symmetric): the link
// is stored as one undirected row, so we union both columns and take the other side.
async function getSubstitutes(db: Db, partId: string) {
  const links = await db
    .select()
    .from(partSubstitutes)
    .where(
      and(
        or(eq(partSubstitutes.partId, partId), eq(partSubstitutes.substitutePartId, partId)),
        isNull(partSubstitutes.deletedAt),
      ),
    );
  if (links.length === 0) return [];

  const otherIds = links.map((l) => (l.partId === partId ? l.substitutePartId : l.partId));
  const noteByOther = new Map(
    links.map((l) => [l.partId === partId ? l.substitutePartId : l.partId, l.note] as const),
  );

  const otherParts = await db.select().from(parts).where(inArray(parts.id, otherIds));
  const nameById = new Map(otherParts.map((p) => [p.id, p.nameNormalized ?? p.nameRaw] as const));

  const nums = await db
    .select({ partId: partNumbers.partId, value: partNumbers.value, isPrimary: partNumbers.isPrimary })
    .from(partNumbers)
    .where(and(inArray(partNumbers.partId, otherIds), isNull(partNumbers.deletedAt)));
  const primaryById = new Map<string, string>();
  for (const n of nums) {
    if (n.isPrimary) primaryById.set(n.partId, n.value);
    else if (!primaryById.has(n.partId)) primaryById.set(n.partId, n.value);
  }

  return otherIds
    .filter((oid) => nameById.has(oid))
    .map((oid) => ({
      partId: oid,
      name: nameById.get(oid)!,
      primaryNumber: primaryById.get(oid) ?? null,
      note: noteByOther.get(oid) ?? null,
    }));
}

// Where this part's numbers are used: each live diagram position, with which
// number/variant/serial range applies there (from item_resolutions).
async function getPlacements(db: Db, numbers: { id: string; value: string }[]) {
  if (numbers.length === 0) return [];
  const numberValueById = new Map(numbers.map((n) => [n.id, n.value]));

  const rows = await db
    .select({
      assemblyItemId: itemResolutions.assemblyItemId,
      partNumberId: itemResolutions.partNumberId,
      qty: itemResolutions.qty,
      variantId: itemResolutions.variantId,
      variantName: machineVariants.name,
      serialFrom: itemResolutions.serialFrom,
      serialTo: itemResolutions.serialTo,
      refNo: assemblyItems.refNo,
      assemblyId: assemblies.id,
      assemblyCode: assemblies.code,
      assemblyName: assemblies.name,
      machineId: machines.id,
      machineBrand: machines.brand,
      machineModel: machines.model,
    })
    .from(itemResolutions)
    .innerJoin(assemblyItems, eq(assemblyItems.id, itemResolutions.assemblyItemId))
    .innerJoin(assemblies, eq(assemblies.id, assemblyItems.assemblyId))
    .innerJoin(machines, eq(machines.id, assemblies.machineId))
    .leftJoin(machineVariants, eq(machineVariants.id, itemResolutions.variantId))
    .where(
      and(
        inArray(itemResolutions.partNumberId, numbers.map((n) => n.id)),
        isNull(itemResolutions.deletedAt),
        isNull(assemblyItems.deletedAt),
        isNull(assemblies.deletedAt),
      ),
    );

  const byItem = new Map<string, {
    assemblyItemId: string;
    refNo: string;
    assemblyId: string;
    assemblyCode: string;
    assemblyName: string;
    machineId: string;
    machine: string;
    applicability: {
      number: string | null;
      qty: number;
      variantId: string | null;
      variantName: string | null;
      serialFrom: string | null;
      serialTo: string | null;
    }[];
  }>();
  for (const r of rows) {
    let placement = byItem.get(r.assemblyItemId);
    if (!placement) {
      placement = {
        assemblyItemId: r.assemblyItemId,
        refNo: r.refNo,
        assemblyId: r.assemblyId,
        assemblyCode: r.assemblyCode,
        assemblyName: r.assemblyName,
        machineId: r.machineId,
        machine: `${r.machineBrand} ${r.machineModel}`,
        applicability: [],
      };
      byItem.set(r.assemblyItemId, placement);
    }
    placement.applicability.push({
      number: numberValueById.get(r.partNumberId) ?? null,
      qty: r.qty,
      variantId: r.variantId,
      variantName: r.variantName,
      serialFrom: r.serialFrom,
      serialTo: r.serialTo,
    });
  }
  return [...byItem.values()];
}

// Resolve ANY part number (oem/alternate/superseded/aftermarket) to its canonical part.
// GET /parts?number=31928-MFF-D01
partsRoute.get('/', async (c) => {
  const number = c.req.query('number');
  if (!number) return c.json({ error: 'number query param is required' }, 400);
  const db = getDb(c.env);
  const pn = await db
    .select({ partId: partNumbers.partId })
    .from(partNumbers)
    .where(eq(partNumbers.value, number))
    .get();
  if (!pn) return c.json({ error: 'not found' }, 404);
  const full = await getPartFull(db, pn.partId);
  return c.json(full);
});

partsRoute.get('/:id', async (c) => {
  const db = getDb(c.env);
  const full = await getPartFull(db, c.req.param('id'));
  if (!full) return c.json({ error: 'not found' }, 404);
  return c.json(full);
});

// --- Substitute links (admin only) ---
// A manual, symmetric link between two DIFFERENT canonical parts that can replace
// each other. Stored as one undirected row, canonically ordered by id string.

const orderedPair = (a: string, b: string): [string, string] => (a < b ? [a, b] : [b, a]);

async function livePart(db: Db, id: string) {
  const p = await db.select().from(parts).where(eq(parts.id, id)).get();
  return p && !p.deletedAt ? p : null;
}

// POST /parts/:id/substitutes  { substitutePartId, note? }
partsRoute.post('/:id/substitutes', requireAdmin, async (c) => {
  const partId = c.req.param('id');
  const body = await c.req.json<{ substitutePartId?: string; note?: string | null }>().catch(() => null);
  const otherId = body?.substitutePartId?.trim();
  if (!otherId) return c.json({ error: 'substitutePartId is required' }, 400);
  if (otherId === partId) return c.json({ error: 'a part cannot substitute itself' }, 400);

  const db = getDb(c.env);
  if (!(await livePart(db, partId))) return c.json({ error: 'part not found' }, 404);
  if (!(await livePart(db, otherId))) return c.json({ error: 'substitute part not found' }, 404);

  const [lo, hi] = orderedPair(partId, otherId);
  const existing = await db
    .select({ id: partSubstitutes.id })
    .from(partSubstitutes)
    .where(
      and(
        eq(partSubstitutes.partId, lo),
        eq(partSubstitutes.substitutePartId, hi),
        isNull(partSubstitutes.deletedAt),
      ),
    )
    .get();
  if (existing) return c.json({ error: 'these parts are already linked as substitutes' }, 409);

  const [row] = await db
    .insert(partSubstitutes)
    .values({ partId: lo, substitutePartId: hi, note: body?.note?.trim() || null })
    .returning();
  return c.json({ ok: true, link: row }, 201);
});

// DELETE /parts/:id/substitutes/:otherId  — soft-delete (tombstone syncs to replicas)
partsRoute.delete('/:id/substitutes/:otherId', requireAdmin, async (c) => {
  const [lo, hi] = orderedPair(c.req.param('id'), c.req.param('otherId'));
  const db = getDb(c.env);
  const now = new Date();
  const updated = await db
    .update(partSubstitutes)
    .set({ deletedAt: now, updatedAt: now })
    .where(
      and(
        eq(partSubstitutes.partId, lo),
        eq(partSubstitutes.substitutePartId, hi),
        isNull(partSubstitutes.deletedAt),
      ),
    )
    .returning({ id: partSubstitutes.id });
  if (updated.length === 0) return c.json({ error: 'link not found' }, 404);
  return c.json({ ok: true });
});
