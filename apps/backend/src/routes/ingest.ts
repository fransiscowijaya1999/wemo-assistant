import { Hono } from 'hono';
import type { Bindings } from '../bindings';
import { requireAdmin } from '../middleware/auth';
import { getVisionProvider } from '../ai';
import type { ImageMediaType } from '../ai/provider';

export const ingestRoute = new Hono<{ Bindings: Bindings }>();

// Admin-only: ingestion is a write-side (catalog-building) operation.
// Returns extracted DRAFT data for admin review; it does not persist yet.
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
