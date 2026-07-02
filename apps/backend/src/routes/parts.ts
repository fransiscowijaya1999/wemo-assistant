import { Hono } from 'hono';
import { and, eq, inArray, isNull } from 'drizzle-orm';
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
  parts,
} from '../db/schema';
import { searchParts } from '../ai/catalog-tools';

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
  return { ...part, numbers, colorVariants, placements };
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
