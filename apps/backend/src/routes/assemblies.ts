import { Hono } from 'hono';
import { and, eq, inArray, isNull } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import {
  assemblies,
  assemblyItems,
  dots,
  itemResolutions,
  machineVariants,
  partNumbers,
  parts,
  serviceItems,
} from '../db/schema';
import { requireAdmin } from '../middleware/auth';
import { serialInRange } from '../lib/serial';

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

// Full assembly: items (with canonical part + numbers), per-position resolutions
// (qty + variant/serial applicability), balloon dots, and the service/FRT items.
// Optional ?variantId= and ?serial= narrow each item's resolutions to the ones that
// apply to that bike (items are never dropped — an empty list means "no match").
assembliesRoute.get('/:id/full', async (c) => {
  const db = getDb(c.env);
  const id = c.req.param('id');
  const variantIdFilter = c.req.query('variantId');
  const serialFilter = c.req.query('serial');

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
    ? await db
        .select()
        .from(itemResolutions)
        .where(and(inArray(itemResolutions.assemblyItemId, itemIds), isNull(itemResolutions.deletedAt)))
    : [];
  const dotRows = itemIds.length
    ? await db.select().from(dots).where(inArray(dots.assemblyItemId, itemIds))
    : [];
  const svc = await db
    .select()
    .from(serviceItems)
    .where(and(eq(serviceItems.assemblyId, id), isNull(serviceItems.deletedAt)));

  const variantRows = await db
    .select({ id: machineVariants.id, name: machineVariants.name })
    .from(machineVariants)
    .where(eq(machineVariants.machineId, assembly.machineId));
  const variantNameById = new Map(variantRows.map((v) => [v.id, v.name]));

  const partById = new Map(partRows.map((p) => [p.id, p]));
  const numberValueById = new Map(numberRows.map((n) => [n.id, n.value]));
  const numbersByPart = new Map<string, typeof numberRows>();
  for (const n of numberRows) {
    const arr = numbersByPart.get(n.partId) ?? [];
    arr.push(n);
    numbersByPart.set(n.partId, arr);
  }
  const enrichedResolutions = resolutionRows
    .filter((r) => {
      if (variantIdFilter && r.variantId !== null && r.variantId !== variantIdFilter) return false;
      if (serialFilter && !serialInRange(serialFilter, r.serialFrom, r.serialTo)) return false;
      return true;
    })
    .map((r) => ({
      ...r,
      variantName: r.variantId ? variantNameById.get(r.variantId) ?? null : null,
      partNumberValue: numberValueById.get(r.partNumberId) ?? null,
    }));
  const resByItem = new Map<string, typeof enrichedResolutions>();
  for (const r of enrichedResolutions) {
    const arr = resByItem.get(r.assemblyItemId) ?? [];
    arr.push(r);
    resByItem.set(r.assemblyItemId, arr);
  }
  const dotsByItem = new Map<string, typeof dotRows>();
  for (const d of dotRows) {
    const arr = dotsByItem.get(d.assemblyItemId) ?? [];
    arr.push(d);
    dotsByItem.set(d.assemblyItemId, arr);
  }

  return c.json({
    assembly,
    items: items.map((i) => {
      const part = i.basePartId ? partById.get(i.basePartId) : undefined;
      return {
        ...i,
        part: part ? { ...part, numbers: numbersByPart.get(part.id) ?? [] } : null,
        resolutions: resByItem.get(i.id) ?? [],
        dots: dotsByItem.get(i.id) ?? [],
      };
    }),
    serviceItems: svc,
  });
});

// Serve the stored diagram image from R2 (open read; clerk views it too).
assembliesRoute.get('/:id/image', async (c) => {
  const obj = await c.env.IMAGES.get(`assemblies/${c.req.param('id')}`);
  if (!obj) return c.json({ error: 'not found' }, 404);
  const headers = new Headers();
  headers.set('Content-Type', obj.httpMetadata?.contentType ?? 'application/octet-stream');
  headers.set('Cache-Control', 'no-cache');
  return new Response(obj.body, { headers });
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

// Store/replace the assembly's diagram image (base64) in R2 and record its dimensions.
assembliesRoute.post('/:id/image', requireAdmin, async (c) => {
  const id = c.req.param('id');
  const db = getDb(c.env);
  const assembly = await db.select({ id: assemblies.id }).from(assemblies).where(eq(assemblies.id, id)).get();
  if (!assembly) return c.json({ error: 'not found' }, 404);

  const body = await c.req
    .json<{ imageBase64?: string; mediaType?: string; width?: number; height?: number }>()
    .catch(() => null);
  if (!body?.imageBase64) return c.json({ error: 'imageBase64 is required' }, 400);

  const binary = Uint8Array.from(atob(body.imageBase64), (ch) => ch.charCodeAt(0));
  const key = `assemblies/${id}`;
  await c.env.IMAGES.put(key, binary, {
    httpMetadata: { contentType: body.mediaType ?? 'image/png' },
  });
  await db
    .update(assemblies)
    .set({ imageRef: key, width: body.width ?? null, height: body.height ?? null, updatedAt: new Date() })
    .where(eq(assemblies.id, id));
  return c.json({ ok: true, imageRef: key });
});

// Replace the full set of balloon dots for this assembly's items (editor saves all at once).
// x/y are normalized 0..1 relative to the diagram image. A position may have several dots.
assembliesRoute.put('/:id/dots', requireAdmin, async (c) => {
  const id = c.req.param('id');
  const db = getDb(c.env);

  const body = await c.req
    .json<{ dots?: { assemblyItemId: string; x: number; y: number }[] }>()
    .catch(() => null);
  if (!body?.dots) return c.json({ error: 'dots array is required' }, 400);

  const items = await db
    .select({ id: assemblyItems.id })
    .from(assemblyItems)
    .where(eq(assemblyItems.assemblyId, id));
  const validItemIds = new Set(items.map((i) => i.id));
  for (const d of body.dots) {
    if (!validItemIds.has(d.assemblyItemId)) {
      return c.json({ error: `dot references an item not in this assembly: ${d.assemblyItemId}` }, 400);
    }
  }

  const itemIds = items.map((i) => i.id);
  if (itemIds.length) await db.delete(dots).where(inArray(dots.assemblyItemId, itemIds));
  // D1 caps bound parameters per statement (~100); a dense diagram can have dozens of
  // dots and each row binds 6 columns, so insert in chunks to stay under the limit.
  const DOTS_PER_INSERT = 15;
  const rows = body.dots.map((d) => ({ assemblyItemId: d.assemblyItemId, x: d.x, y: d.y }));
  for (let i = 0; i < rows.length; i += DOTS_PER_INSERT) {
    await db.insert(dots).values(rows.slice(i, i + DOTS_PER_INSERT));
  }
  return c.json({ ok: true, count: body.dots.length });
});
