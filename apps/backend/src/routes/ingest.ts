import { Hono } from 'hono';
import { eq } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { requireAdmin } from '../middleware/auth';
import { getVisionProvider } from '../ai';
import type { ImageMediaType } from '../ai/provider';
import { extractedPage } from '../ai/types';
import { getDb } from '../db/client';
import { machines } from '../db/schema';
import { persistExtractedPage } from '../services/ingest-persist';

export const ingestRoute = new Hono<{ Bindings: Bindings }>();

// Extract a catalog page image -> structured DRAFT (admin reviews before committing).
// Admin-only: ingestion is a write-side (catalog-building) operation.
ingestRoute.post('/page', requireAdmin, async (c) => {
  const body = await c.req.json<{ imageBase64?: string; mediaType?: string }>().catch(() => null);
  if (!body?.imageBase64) {
    return c.json({ error: 'imageBase64 is required' }, 400);
  }
  const mediaType = (body.mediaType ?? 'image/png') as ImageMediaType;

  const provider = getVisionProvider(c.env);
  try {
    const extracted = await provider.extractCatalogPage({ imageBase64: body.imageBase64, mediaType });
    return c.json({ extracted });
  } catch (e) {
    return c.json({ error: 'extraction failed', detail: String(e) }, 502);
  }
});

// Persist a reviewed draft into the catalog. Parts are deduped by part number
// (an existing number reuses its canonical part = interchange merge).
ingestRoute.post('/commit', requireAdmin, async (c) => {
  const body = await c.req
    .json<{ machineId?: string; groupType?: string; extracted?: unknown }>()
    .catch(() => null);
  if (!body?.machineId || !body?.groupType || body.extracted === undefined) {
    return c.json({ error: 'machineId, groupType, extracted are required' }, 400);
  }
  if (body.groupType !== 'engine' && body.groupType !== 'frame') {
    return c.json({ error: "groupType must be 'engine' or 'frame'" }, 400);
  }
  const parsed = extractedPage.safeParse(body.extracted);
  if (!parsed.success) {
    return c.json({ error: 'invalid extracted payload', detail: parsed.error.issues }, 400);
  }

  const db = getDb(c.env);
  const machine = await db
    .select({ id: machines.id })
    .from(machines)
    .where(eq(machines.id, body.machineId))
    .get();
  if (!machine) return c.json({ error: 'machine not found' }, 404);

  const summary = await persistExtractedPage(db, {
    machineId: body.machineId,
    groupType: body.groupType,
    extracted: parsed.data,
  });
  return c.json({ ok: true, summary }, 201);
});
