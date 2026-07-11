import { Hono } from 'hono';
import { and, eq, isNull } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import { customerVehicles, maintenanceRecords } from '../db/schema';
import { requireClerkWrite, requireClerkRead } from '../middleware/auth';

export const vehiclesRoute = new Hono<{ Bindings: Bindings }>();

// --- Reads ---

vehiclesRoute.get('/:id', requireClerkRead, async (c) => {
  const db = getDb(c.env);
  const id = c.req.param('id');
  const vehicle = await db
    .select()
    .from(customerVehicles)
    .where(eq(customerVehicles.id, id))
    .get();
  if (!vehicle) return c.json({ error: 'not found' }, 404);
  return c.json(vehicle);
});

vehiclesRoute.get('/:id/records', requireClerkRead, async (c) => {
  const db = getDb(c.env);
  const id = c.req.param('id');
  const records = await db
    .select()
    .from(maintenanceRecords)
    .where(and(eq(maintenanceRecords.customerVehicleId, id), isNull(maintenanceRecords.deletedAt)));
  return c.json(records);
});

// --- Writes ---

vehiclesRoute.put('/:id', requireClerkWrite, async (c) => {
  const id = c.req.param('id');
  const body = await c.req.json().catch(() => null);
  if (!body || typeof body !== 'object') return c.json({ error: 'invalid body' }, 400);
  const db = getDb(c.env);
  const existing = await db.select({ id: customerVehicles.id }).from(customerVehicles).where(eq(customerVehicles.id, id)).get();
  if (!existing) return c.json({ error: 'not found' }, 404);
  const updateData = { ...body };
  delete updateData.id;
  delete updateData.createdAt;
  delete updateData.deletedAt;
  const [row] = await db.update(customerVehicles).set(updateData).where(eq(customerVehicles.id, id)).returning();
  return c.json(row);
});

vehiclesRoute.delete('/:id', requireClerkWrite, async (c) => {
  const id = c.req.param('id');
  const db = getDb(c.env);
  const existing = await db.select({ id: customerVehicles.id }).from(customerVehicles).where(eq(customerVehicles.id, id)).get();
  if (!existing) return c.json({ error: 'not found' }, 404);
  await db.update(customerVehicles).set({ deletedAt: new Date() }).where(eq(customerVehicles.id, id));
  return c.json({ ok: true });
});