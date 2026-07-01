import { Hono } from 'hono';
import { and, eq, isNull } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import { assemblies } from '../db/schema';
import { requireAdmin } from '../middleware/auth';

export const assembliesRoute = new Hono<{ Bindings: Bindings }>();

// --- Reads ---

assembliesRoute.get('/', async (c) => {
  const db = getDb(c.env);
  const machineId = c.req.query('machineId');
  const rows = await db
    .select()
    .from(assemblies)
    .where(
      machineId
        ? and(eq(assemblies.machineId, machineId), isNull(assemblies.deletedAt))
        : isNull(assemblies.deletedAt),
    );
  return c.json(rows);
});

assembliesRoute.get('/:id', async (c) => {
  const db = getDb(c.env);
  const row = await db.select().from(assemblies).where(eq(assemblies.id, c.req.param('id'))).get();
  if (!row) return c.json({ error: 'not found' }, 404);
  return c.json(row);
});

// --- Writes (admin only) ---

assembliesRoute.post('/', requireAdmin, async (c) => {
  const body = await c.req.json<Partial<typeof assemblies.$inferInsert>>().catch(() => null);
  if (!body?.machineId || !body?.code || !body?.name || !body?.groupType) {
    return c.json({ error: 'machineId, groupType, code, name are required' }, 400);
  }
  if (body.groupType !== 'engine' && body.groupType !== 'frame') {
    return c.json({ error: "groupType must be 'engine' or 'frame'" }, 400);
  }
  const db = getDb(c.env);
  const [row] = await db
    .insert(assemblies)
    .values({
      machineId: body.machineId,
      groupType: body.groupType,
      code: body.code,
      name: body.name,
      imageCode: body.imageCode ?? null,
      pageNo: body.pageNo ?? null,
      sortOrder: body.sortOrder ?? null,
    })
    .returning();
  return c.json(row, 201);
});
