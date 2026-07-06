import { getTableColumns, sql } from 'drizzle-orm';
import type { Db } from '../db/client';
import * as schema from '../db/schema';

// ---------------------------------------------------------------------------
// Full catalog backup / restore.
//
// The point: the token-expensive part of building the catalog is AI extraction,
// and its output lands as rows in D1 + cropped diagram images in R2. This lets
// you snapshot ALL of it from one deployment (e.g. local dev) and replay it into
// another (e.g. prod) over HTTP, without re-running any extraction.
//
// Scope: the 14 catalog/data tables + every R2 diagram image they reference.
// Deliberately EXCLUDES `app_settings` (holds AI secrets) and `users` (auth) —
// those are per-deployment, not catalog data.
//
// Restore is idempotent: rows are upserted by primary key (INSERT ... ON CONFLICT
// DO UPDATE via `excluded`), so restoring into an empty prod or re-restoring over
// an existing one both converge to the snapshot.
// ---------------------------------------------------------------------------

/** Catalog tables in FK-parent-first order (safe for restore even if FKs are enforced). */
const TABLE_ORDER = [
  ['machines', schema.machines],
  ['machineVariants', schema.machineVariants],
  ['colors', schema.colors],
  ['parts', schema.parts],
  ['partNumbers', schema.partNumbers],
  ['partColorVariants', schema.partColorVariants],
  ['aliases', schema.aliases],
  ['partSubstitutes', schema.partSubstitutes],
  ['assemblies', schema.assemblies],
  ['assemblyItems', schema.assemblyItems],
  ['itemResolutions', schema.itemResolutions],
  ['dots', schema.dots],
  ['assemblyLinks', schema.assemblyLinks],
  ['serviceItems', schema.serviceItems],
] as const;

/** Timestamp columns shared by every syncable table (drizzle hands these back as Date). */
const TS_FIELDS = ['createdAt', 'updatedAt', 'deletedAt'] as const;

export const BACKUP_VERSION = 1;

export interface BackupArchive {
  version: number;
  exportedAt: number;
  counts: Record<string, number>;
  imageCount: number;
  tables: Record<string, Record<string, unknown>[]>;
  images: { key: string; contentType: string; dataBase64: string }[];
}

export class RestoreError extends Error {}

// --- serialization: Date <-> ms epoch (JSON has no Date) ---

function serializeRow(row: Record<string, unknown>): Record<string, unknown> {
  const out = { ...row };
  for (const f of TS_FIELDS) if (out[f] instanceof Date) out[f] = (out[f] as Date).getTime();
  return out;
}

function deserializeRow(row: Record<string, unknown>): Record<string, unknown> {
  const out = { ...row };
  for (const f of TS_FIELDS) if (out[f] != null) out[f] = new Date(out[f] as number);
  return out;
}

// --- base64 for R2 image bytes (chunked to avoid call-stack blowup) ---

function bytesToBase64(bytes: Uint8Array): string {
  let bin = '';
  const chunk = 0x8000;
  for (let i = 0; i < bytes.length; i += chunk) {
    bin += String.fromCharCode(...bytes.subarray(i, i + chunk));
  }
  return btoa(bin);
}

function base64ToBytes(b64: string): Uint8Array {
  const bin = atob(b64);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes;
}

/** Read the whole catalog + its diagram images into a single portable archive. */
export async function buildBackup(db: Db, images: R2Bucket): Promise<BackupArchive> {
  const tables: Record<string, Record<string, unknown>[]> = {};
  const counts: Record<string, number> = {};
  const imageKeys: string[] = [];

  for (const [name, table] of TABLE_ORDER) {
    const rows = (await db.select().from(table as never)) as Record<string, unknown>[];
    tables[name] = rows.map(serializeRow);
    counts[name] = rows.length;
    if (name === 'assemblies') {
      for (const r of rows) if (typeof r.imageRef === 'string') imageKeys.push(r.imageRef);
    }
  }

  const blobs: BackupArchive['images'] = [];
  for (const key of imageKeys) {
    const obj = await images.get(key);
    if (!obj) continue; // row references an image that isn't in R2 — skip, don't fail
    const buf = new Uint8Array(await obj.arrayBuffer());
    blobs.push({
      key,
      contentType: obj.httpMetadata?.contentType ?? 'image/png',
      dataBase64: bytesToBase64(buf),
    });
  }

  return { version: BACKUP_VERSION, exportedAt: Date.now(), counts, imageCount: blobs.length, tables, images: blobs };
}

/**
 * Build the chunked upsert statements for one table's rows (does NOT execute).
 * Returned statements are run later via `db.batch()` so a whole group of inserts
 * costs a single Worker subrequest — a full-catalog restore is thousands of rows,
 * and one-subrequest-per-chunk blows the 1000/invocation limit.
 */
function buildUpsertStatements(table: unknown, rows: Record<string, unknown>[], db: Db): BatchStatement[] {
  if (!rows.length) return [];
  // Heterogeneous tables in one loop — drizzle's per-table generics don't help here, so use `any`.
  /* eslint-disable @typescript-eslint/no-explicit-any */
  const t = table as any;
  const cols = getTableColumns(t) as Record<string, { name: string; primary: boolean }>;
  const entries = Object.entries(cols);
  const pkProp = entries.find(([, c]) => c.primary)?.[0] ?? 'id';
  const set = Object.fromEntries(
    entries.filter(([, c]) => !c.primary).map(([prop, c]) => [prop, sql`excluded.${sql.identifier(c.name)}`]),
  );
  // D1 caps bound parameters per query at 100; size chunks by column count.
  const perChunk = Math.max(1, Math.floor(90 / entries.length));
  const stmts: BatchStatement[] = [];
  for (let i = 0; i < rows.length; i += perChunk) {
    const chunk = rows.slice(i, i + perChunk);
    stmts.push((db as any).insert(t).values(chunk).onConflictDoUpdate({ target: t[pkProp], set }));
  }
  /* eslint-enable @typescript-eslint/no-explicit-any */
  return stmts;
}

// A prepared (not-yet-awaited) drizzle statement, as accepted by `db.batch()`.
// eslint-disable-next-line @typescript-eslint/no-explicit-any
type BatchStatement = any;

// Max prepared statements per `db.batch()` call. Each batch is one subrequest and
// runs its statements sequentially in an implicit transaction, so ordering (and
// thus FK-parent-first) is preserved across a batch.
const BATCH_STATEMENTS = 20;

async function runInBatches(db: Db, stmts: BatchStatement[]): Promise<void> {
  for (let i = 0; i < stmts.length; i += BATCH_STATEMENTS) {
    const group = stmts.slice(i, i + BATCH_STATEMENTS);
    // drizzle's batch wants a non-empty tuple; the slice is always non-empty here.
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    await (db as any).batch(group as [BatchStatement, ...BatchStatement[]]);
  }
}

/** Replay an archive into this deployment's D1 + R2 (idempotent upsert). */
export async function restoreBackup(
  db: Db,
  images: R2Bucket,
  archive: unknown,
): Promise<{ counts: Record<string, number>; imageCount: number }> {
  const a = archive as Partial<BackupArchive> | null;
  if (!a || a.version !== BACKUP_VERSION || typeof a.tables !== 'object' || !a.tables) {
    throw new RestoreError(`unrecognized backup (expected version ${BACKUP_VERSION})`);
  }

  // Collect every table's upsert statements in FK-parent-first order, then run them
  // in batched groups. Order is preserved within and across batches, so children
  // never land before their parents.
  const counts: Record<string, number> = {};
  const stmts: BatchStatement[] = [];
  for (const [name, table] of TABLE_ORDER) {
    const rows = Array.isArray(a.tables[name]) ? a.tables[name] : [];
    counts[name] = rows.length;
    stmts.push(...buildUpsertStatements(table, rows.map(deserializeRow), db));
  }
  await runInBatches(db, stmts);

  let imageCount = 0;
  for (const img of a.images ?? []) {
    if (!img?.key || !img?.dataBase64) continue;
    await images.put(img.key, base64ToBytes(img.dataBase64), {
      httpMetadata: { contentType: img.contentType ?? 'image/png' },
    });
    imageCount++;
  }

  return { counts, imageCount };
}
