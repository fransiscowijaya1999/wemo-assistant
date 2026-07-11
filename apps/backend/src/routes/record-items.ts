import { Hono } from 'hono';
import { eq } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import { maintenanceItems, maintenanceRecords } from '../db/schema';
import { requireClerkWrite, requireClerkRead } from '../middleware/auth';

export const recordItemsRoute = new Hono<{ Bindings: Bindings }>();

// --- Reads ---

recordItemsRoute.get('/:id', requireClerkRead, async (c) => {
  const db = getDb(c.env);
  const id = c.req.param('id');
  const item = await db
    .select()
    .from(maintenanceItems)
    .where(eq(maintenanceItems.id, id))
    .get();
  if (!item) return c.json({ error: 'not found' }, 404);
  return c.json(item);
});

// --- Writes ---

recordItemsRoute.post('/:recordId/items', requireClerkWrite, async (c) => {
  const recordId = c.req.param('recordId');
  const body = await c.req.json().catch(() => null);
  if (!body?.category) return c.json({ error: 'category is required' }, 400);
  
  const db = getDb(c.env);
  // Verify record exists
  const record = await db
    .select({ id: maintenanceRecords.id })
    .from(maintenanceRecords)
    .where(eq(maintenanceRecords.id, recordId))
    .get();
  if (!record) return c.json({ error: 'record not found' }, 404);
  
  const [row] = await db.insert(maintenanceItems).values({
    maintenanceRecordId: recordId,
    category: body.category
  }).returning();
  return c.json(row, 201);
});

recordItemsRoute.put('/:id', requireClerkWrite, async (c) => {
  const id = c.req.param('id');
  const body = await c.req.json().catch(() => null);
  if (!body || typeof body !== 'object') return c.json({ error: 'invalid body' }, 400);
  const db = getDb(c.env);
  const existing = await db.select({ id: maintenanceItems.id }).from(maintenanceItems).where(eq(maintenanceItems.id, id)).get();
  if (!existing) return c.json({ error: 'not found' }, 404);
  const updateData = { ...body };
  delete updateData.id;
  delete updateData.createdAt;
  delete updateData.deletedAt;
  const [row] = await db.update(maintenanceItems).set(updateData).where(eq(maintenanceItems.id, id)).returning();
  return c.json(row);
});

recordItemsRoute.delete('/:id', requireClerkWrite, async (c) => {
  const id = c.req.param('id');
  const db = getDb(c.env);
  const existing = await db.select({ id: maintenanceItems.id }).from(maintenanceItems).where(eq(maintenanceItems.id, id)).get();
  if (!existing) return c.json({ error: 'not found' }, 404);
  await db.update(maintenanceItems).set({ deletedAt: new Date() }).where(eq(maintenanceItems.id, id));
  return c.json({ ok: true });
});