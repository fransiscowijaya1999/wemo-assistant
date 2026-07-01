import { Hono } from 'hono';
import { eq, isNull } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import { machines } from '../db/schema';
import { requireAdmin } from '../middleware/auth';

export const machinesRoute = new Hono<{ Bindings: Bindings }>();

// --- Reads (clerk-facing; auth added in a later slice, always read-only) ---

machinesRoute.get('/', async (c) => {
  const db = getDb(c.env);
  const rows = await db.select().from(machines).where(isNull(machines.deletedAt));
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
