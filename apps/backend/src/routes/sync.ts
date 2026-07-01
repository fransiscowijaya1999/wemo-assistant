import { Hono } from 'hono';
import { gt } from 'drizzle-orm';
import type { Bindings } from '../bindings';
import { getDb } from '../db/client';
import {
  aliases,
  assemblies,
  assemblyItems,
  assemblyLinks,
  colors,
  dots,
  itemResolutions,
  machineVariants,
  machines,
  partColorVariants,
  partNumbers,
  parts,
  serviceItems,
} from '../db/schema';

export const syncRoute = new Hono<{ Bindings: Bindings }>();

// Catalog tables the clerk replica needs (everything except `users`). Typed loosely
// because they are aggregated in one loop; each has an `updatedAt` column.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const SYNC_TABLES: { name: string; table: any }[] = [
  { name: 'machines', table: machines },
  { name: 'machineVariants', table: machineVariants },
  { name: 'colors', table: colors },
  { name: 'assemblies', table: assemblies },
  { name: 'assemblyItems', table: assemblyItems },
  { name: 'itemResolutions', table: itemResolutions },
  { name: 'dots', table: dots },
  { name: 'assemblyLinks', table: assemblyLinks },
  { name: 'parts', table: parts },
  { name: 'partNumbers', table: partNumbers },
  { name: 'partColorVariants', table: partColorVariants },
  { name: 'aliases', table: aliases },
  { name: 'serviceItems', table: serviceItems },
];

// Delta sync for the offline clerk replica.
//   GET /sync?since=<ms epoch>   (0 or omitted = full catalog)
// Returns rows changed since `since` (INCLUDING soft-deleted rows, so the client can
// remove them), plus a `cursor` to pass as `since` next time. Diagram images are fetched
// separately per assembly via GET /assemblies/:id/image.
syncRoute.get('/', async (c) => {
  const sinceMs = Number(c.req.query('since') ?? '0') || 0;
  const since = new Date(sinceMs);
  const db = getDb(c.env);

  const tables: Record<string, unknown[]> = {};
  let cursor = sinceMs;

  for (const { name, table } of SYNC_TABLES) {
    const rows = (await db.select().from(table).where(gt(table.updatedAt, since))) as {
      updatedAt: Date | number | string;
    }[];
    tables[name] = rows;
    for (const r of rows) {
      const t = r.updatedAt instanceof Date ? r.updatedAt.getTime() : new Date(r.updatedAt).getTime();
      if (t > cursor) cursor = t;
    }
  }

  return c.json({ since: sinceMs, cursor, tables });
});
