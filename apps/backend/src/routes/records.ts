import { Hono } from 'hono';
import { and, eq, isNull } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import { maintenanceRecords, maintenanceItems } from '../db/schema';
import { requireClerkWrite, requireClerkRead } from '../middleware/auth';

export const recordsRoute = new Hono<{ Bindings: Bindings }>();

// --- Reads ---

recordsRoute.get('/', requireClerkRead, async (c) => {
  const db = getDb(c.env);
  const customerId = c.req.query('customerId');
  const vehicleId = c.req.query('vehicleId');
  const type = c.req.query('type');
  
  const conditions = [isNull(maintenanceRecords.deletedAt)];
  if (customerId) conditions.push(eq(maintenanceRecords.customerId as any, customerId));
  if (vehicleId) conditions.push(eq(maintenanceRecords.customerVehicleId as any, vehicleId));
  if (type && ['service', 'purchase'].includes(type)) {
    conditions.push(eq(maintenanceRecords.type as any, type));
  }
  
  const rows = await db.select().from(maintenanceRecords).where(and(...conditions));
  return c.json(rows);
});

recordsRoute.get('/:id', requireClerkRead, async (c) => {
  const db = getDb(c.env);
  const id = c.req.param('id');
  const record = await db
    .select()
    .from(maintenanceRecords)
    .where(eq(maintenanceRecords.id, id))
    .get();
  if (!record) return c.json({ error: 'not found' }, 404);
  return c.json(record);
});

recordsRoute.get('/:id/items', requireClerkRead, async (c) => {
  const db = getDb(c.env);
  const id = c.req.param('id');
  const items = await db
    .select()
    .from(maintenanceItems)
    .where(and(eq(maintenanceItems.maintenanceRecordId, id), isNull(maintenanceItems.deletedAt)));
  return c.json(items);
});

// --- Writes ---

recordsRoute.post('/', requireClerkWrite, async (c) => {
  const body = await c.req.json().catch(() => null);
  if (!body?.customerId || !body?.description || !body?.type) {
    return c.json({ error: 'customerId, description, and type are required' }, 400);
  }
  if (!['service', 'purchase'].includes(body.type)) {
    return c.json({ error: 'type must be "service" or "purchase"' }, 400);
  }
  const db = getDb(c.env);
  const [row] = await db.insert(maintenanceRecords).values({
    customerId: body.customerId,
    customerVehicleId: body.customerVehicleId ?? null,
    type: body.type,
    description: body.description
  }).returning();
  return c.json(row, 201);
});

recordsRoute.put('/:id', requireClerkWrite, async (c) => {
  const id = c.req.param('id');
  const body = await c.req.json().catch(() => null);
  if (!body || typeof body !== 'object') return c.json({ error: 'invalid body' }, 400);
  const db = getDb(c.env);
  const existing = await db.select({ id: maintenanceRecords.id }).from(maintenanceRecords).where(eq(maintenanceRecords.id, id)).get();
  if (!existing) return c.json({ error: 'not found' }, 404);
  const updateData = { ...body };
  delete updateData.id;
  delete updateData.createdAt;
  delete updateData.deletedAt;
  const [row] = await db.update(maintenanceRecords).set(updateData).where(eq(maintenanceRecords.id, id)).returning();
  return c.json(row);
});

recordsRoute.delete('/:id', requireClerkWrite, async (c) => {
  const id = c.req.param('id');
  const db = getDb(c.env);
  const existing = await db.select({ id: maintenanceRecords.id }).from(maintenanceRecords).where(eq(maintenanceRecords.id, id)).get();
  if (!existing) return c.json({ error: 'not found' }, 404);
  await db.update(maintenanceRecords).set({ deletedAt: new Date() }).where(eq(maintenanceRecords.id, id));
  return c.json({ ok: true });
});