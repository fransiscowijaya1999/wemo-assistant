import { Hono } from 'hono';
import { and, asc, eq, isNull } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import { machines, machineVariants } from '../db/schema';
import { requireAdmin } from '../middleware/auth';

export const machinesRoute = new Hono<{ Bindings: Bindings }>();

// --- Reads (clerk-facing; auth added in a later slice, always read-only) ---

machinesRoute.get('/', async (c) => {
  const db = getDb(c.env);
  const rows = await db.select().from(machines).where(isNull(machines.deletedAt));
  return c.json(rows);
});

// Variants (STD/ABS/...) for a machine. Usually created implicitly at ingest commit;
// this list is the inspection surface.
machinesRoute.get('/:id/variants', async (c) => {
  const db = getDb(c.env);
  const rows = await db
    .select()
    .from(machineVariants)
    .where(and(eq(machineVariants.machineId, c.req.param('id')), isNull(machineVariants.deletedAt)))
    .orderBy(asc(machineVariants.name));
  return c.json(rows);
});

machinesRoute.get('/:id', async (c) => {
  const db = getDb(c.env);
  const row = await db.select().from(machines).where(eq(machines.id, c.req.param('id'))).get();
  if (!row) return c.json({ error: 'not found' }, 404);
  return c.json(row);
});

// --- Writes (admin only) ---

machinesRoute.post('/', requireAdmin, async (c) => {
  const body = await c.req.json<Partial<typeof machines.$inferInsert>>().catch(() => null);
  if (!body?.brand || !body?.model) {
    return c.json({ error: 'brand and model are required' }, 400);
  }
  const db = getDb(c.env);
  const [row] = await db
    .insert(machines)
    .values({
      brand: body.brand,
      model: body.model,
      typeCode: body.typeCode ?? null,
      kCode: body.kCode ?? null,
      market: body.market ?? null,
      engineSeries: body.engineSeries ?? null,
      frameSeries: body.frameSeries ?? null,
      yearFrom: body.yearFrom ?? null,
      yearTo: body.yearTo ?? null,
      catalogEdition: body.catalogEdition ?? null,
      catalogDate: body.catalogDate ?? null,
      notes: body.notes ?? null,
    })
    .returning();
  return c.json(row, 201);
});

// Manual-fix escape hatch: variants are normally get-or-created at ingest commit.
// Deduped case-insensitively per machine — returns the existing row with 200 if present.
machinesRoute.post('/:id/variants', requireAdmin, async (c) => {
  const machineId = c.req.param('id');
  const body = await c.req.json<{ name?: string; note?: string }>().catch(() => null);
  const name = body?.name?.trim();
  if (!name) return c.json({ error: 'name is required' }, 400);

  const db = getDb(c.env);
  const machine = await db.select({ id: machines.id }).from(machines).where(eq(machines.id, machineId)).get();
  if (!machine) return c.json({ error: 'machine not found' }, 404);

  const existing = await db
    .select()
    .from(machineVariants)
    .where(and(eq(machineVariants.machineId, machineId), isNull(machineVariants.deletedAt)));
  const dup = existing.find((v) => v.name.trim().toLowerCase() === name.toLowerCase());
  if (dup) return c.json(dup, 200);

  const [row] = await db
    .insert(machineVariants)
    .values({ machineId, name, note: body?.note ?? null })
    .returning();
  return c.json(row, 201);
});
