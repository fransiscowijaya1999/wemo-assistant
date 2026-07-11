import { Hono } from 'hono';
import { and, eq, isNull } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import { customers, customerVehicles, maintenanceRecords } from '../db/schema';
import { requireClerkWrite, requireClerkRead } from '../middleware/auth';

export const customersRoute = new Hono<{ Bindings: Bindings }>();

// --- Reads ---

customersRoute.get('/', requireClerkRead, async (c) => {
  const db = getDb(c.env);
  const rows = await db.select().from(customers).where(isNull(customers.deletedAt));
  return c.json(rows);
});

customersRoute.get('/:id', requireClerkRead, async (c) => {
  const db = getDb(c.env);
  const id = c.req.param('id');
  const row = await db.select().from(customers).where(eq(customers.id, id)).get();
  if (!row) return c.json({ error: 'not found' }, 404);
  return c.json(row);
});

customersRoute.get('/:id/vehicles', requireClerkRead, async (c) => {
  const db = getDb(c.env);
  const id = c.req.param('id');
  const vehicles = await db
    .select()
    .from(customerVehicles)
    .where(and(eq(customerVehicles.customerId, id), isNull(customerVehicles.deletedAt)));
  return c.json(vehicles);
});

customersRoute.get('/:id/records', requireClerkRead, async (c) => {
  const db = getDb(c.env);
  const id = c.req.param('id');
  const records = await db
    .select()
    .from(maintenanceRecords)
    .where(and(eq(maintenanceRecords.customerId, id), isNull(maintenanceRecords.deletedAt)));
  return c.json(records);
});

// --- Writes ---

customersRoute.post('/', requireClerkWrite, async (c) => {
  const body = await c.req.json().catch(() => null);
  if (!body?.name) return c.json({ error: 'name is required' }, 400);
  const db = getDb(c.env);
  const [row] = await db.insert(customers).values({ name: body.name }).returning();
  return c.json(row, 201);
});

customersRoute.put('/:id', requireClerkWrite, async (c) => {
  const id = c.req.param('id');
  const body = await c.req.json().catch(() => null);
  if (!body || typeof body !== 'object') return c.json({ error: 'invalid body' }, 400);
  const db = getDb(c.env);
  const existing = await db.select({ id: customers.id }).from(customers).where(eq(customers.id, id)).get();
  if (!existing) return c.json({ error: 'not found' }, 404);
  const updateData = { ...body };
  delete updateData.id;
  delete updateData.createdAt;
  delete updateData.deletedAt;
  const [row] = await db.update(customers).set(updateData).where(eq(customers.id, id)).returning();
  return c.json(row);
});

customersRoute.delete('/:id', requireClerkWrite, async (c) => {
  const id = c.req.param('id');
  const db = getDb(c.env);
  const existing = await db.select({ id: customers.id }).from(customers).where(eq(customers.id, id)).get();
  if (!existing) return c.json({ error: 'not found' }, 404);
  await db.update(customers).set({ deletedAt: new Date() }).where(eq(customers.id, id));
  return c.json({ ok: true });
});

// Vehicle CRUD
customersRoute.post('/:id/vehicles', requireClerkWrite, async (c) => {
  const customerId = c.req.param('id');
  const body = await c.req.json().catch(() => null);
  if (!body?.machineId) return c.json({ error: 'machineId is required' }, 400);
  const db = getDb(c.env);
  const [row] = await db.insert(customerVehicles).values({ customerId, machineId: body.machineId }).returning();
  return c.json(row, 201);
});