import { Hono } from 'hono';
import { eq } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import type { Db } from '../db/client';
import { partColorVariants, partNumbers, parts } from '../db/schema';

export const partsRoute = new Hono<{ Bindings: Bindings }>();

async function getPartFull(db: Db, id: string) {
  const part = await db.select().from(parts).where(eq(parts.id, id)).get();
  if (!part) return null;
  const numbers = await db.select().from(partNumbers).where(eq(partNumbers.partId, id));
  const colorVariants = await db.select().from(partColorVariants).where(eq(partColorVariants.partId, id));
  return { ...part, numbers, colorVariants };
}

// Resolve ANY part number (oem/alternate/superseded/aftermarket) to its canonical part.
// GET /parts?number=31928-MFF-D01
partsRoute.get('/', async (c) => {
  const number = c.req.query('number');
  if (!number) return c.json({ error: 'number query param is required' }, 400);
  const db = getDb(c.env);
  const pn = await db
    .select({ partId: partNumbers.partId })
    .from(partNumbers)
    .where(eq(partNumbers.value, number))
    .get();
  if (!pn) return c.json({ error: 'not found' }, 404);
  const full = await getPartFull(db, pn.partId);
  return c.json(full);
});

partsRoute.get('/:id', async (c) => {
  const db = getDb(c.env);
  const full = await getPartFull(db, c.req.param('id'));
  if (!full) return c.json({ error: 'not found' }, 404);
  return c.json(full);
});
