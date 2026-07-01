import { Hono } from 'hono';
import { and, eq, inArray, isNull } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import { assemblies, assemblyItems, itemResolutions, partNumbers, parts, serviceItems } from '../db/schema';
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

// Full assembly with its items, each item's canonical part + all its numbers, the
// per-position resolutions (qty), and the service/FRT items.
assembliesRoute.get('/:id/full', async (c) => {
  const db = getDb(c.env);
  const id = c.req.param('id');

  const assembly = await db.select().from(assemblies).where(eq(assemblies.id, id)).get();
  if (!assembly) return c.json({ error: 'not found' }, 404);

  const items = await db
    .select()
    .from(assemblyItems)
    .where(and(eq(assemblyItems.assemblyId, id), isNull(assemblyItems.deletedAt)));

  const partIds = [...new Set(items.map((i) => i.basePartId).filter((x): x is string => !!x))];
  const itemIds = items.map((i) => i.id);

  const partRows = partIds.length ? await db.select().from(parts).where(inArray(parts.id, partIds)) : [];
  const numberRows = partIds.length
    ? await db.select().from(partNumbers).where(inArray(partNumbers.partId, partIds))
    : [];
  const resolutionRows = itemIds.length
    ? await db.select().from(itemResolutions).where(inArray(itemResolutions.assemblyItemId, itemIds))
    : [];
  const svc = await db
    .select()
    .from(serviceItems)
    .where(and(eq(serviceItems.assemblyId, id), isNull(serviceItems.deletedAt)));

  const partById = new Map(partRows.map((p) => [p.id, p]));
  const numbersByPart = new Map<string, typeof numberRows>();
  for (const n of numberRows) {
    const arr = numbersByPart.get(n.partId) ?? [];
    arr.push(n);
    numbersByPart.set(n.partId, arr);
  }
  const resByItem = new Map<string, typeof resolutionRows>();
  for (const r of resolutionRows) {
    const arr = resByItem.get(r.assemblyItemId) ?? [];
    arr.push(r);
    resByItem.set(r.assemblyItemId, arr);
  }

  return c.json({
    assembly,
    items: items.map((i) => {
      const part = i.basePartId ? partById.get(i.basePartId) : undefined;
      return {
        ...i,
        part: part ? { ...part, numbers: numbersByPart.get(part.id) ?? [] } : null,
        resolutions: resByItem.get(i.id) ?? [],
      };
    }),
    serviceItems: svc,
  });
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
