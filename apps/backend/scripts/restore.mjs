#!/usr/bin/env node
// Replay a backup JSON into a deployment's D1 + R2 (idempotent upsert).
//
//   bun run restore backups/wemo-….json                      # into local dev
//   ADMIN_TOKEN=<prod> bun run restore backups/wemo-….json https://prod
//
// The archive is sent in bounded SLICES across several POSTs, not one giant
// request: every D1 query and R2 put counts against the Workers per-invocation
// subrequest limit (50 on Free, 1000+ on Paid), and a full catalog is thousands
// of rows + ~100 images — far past 50 in a single call. Restore is idempotent
// upsert, so each slice is just a smaller valid archive. Tables are sent in
// FK-parent-first order (and fully, per table) before the next, so children
// never reach the server before their parents.
import { readFile } from 'node:fs/promises';

const file = process.argv[2];
if (!file) {
  console.error('Usage: bun run restore <backup.json> [url]   (token via ADMIN_TOKEN env)');
  process.exit(1);
}
// 127.0.0.1 (not "localhost") — Node's fetch prefers IPv6 ::1, which wrangler dev doesn't bind on Windows.
const base = (process.argv[3] || process.env.RESTORE_URL || 'http://127.0.0.1:8787').replace(/\/$/, '');
const token = process.env.ADMIN_TOKEN || 'dev-admin-key';

const BACKUP_VERSION = 1;
// FK-parent-first — must match TABLE_ORDER in src/services/backup.ts.
const TABLE_ORDER = [
  'machines', 'machineVariants', 'colors', 'parts', 'partNumbers', 'partColorVariants',
  'aliases', 'partSubstitutes', 'assemblies', 'assemblyItems', 'itemResolutions',
  'dots', 'assemblyLinks', 'serviceItems',
];
// Sized so one slice stays well under the Free plan's 50 subrequests, even after
// the server chunks rows into batched inserts (~1 subrequest per 20 statements).
const ROWS_PER_REQUEST = 800;
const IMAGES_PER_REQUEST = 20;

const archive = JSON.parse(await readFile(file, 'utf8'));
if (archive?.version !== BACKUP_VERSION) {
  console.error(`Unrecognized backup (expected version ${BACKUP_VERSION}, got ${archive?.version}).`);
  process.exit(1);
}

async function postSlice(slice, label) {
  const res = await fetch(`${base}/admin/restore`, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(slice),
  });
  const out = await res.json().catch(() => ({}));
  if (!res.ok) {
    console.error(`Restore failed on ${label}: ${res.status} ${res.statusText}`, out);
    process.exit(1);
  }
  return out;
}

const emptyTables = () => Object.fromEntries(TABLE_ORDER.map((n) => [n, []]));
let totalRows = 0;
let totalImages = 0;

// 1. Tables, parents first, paged.
for (const name of TABLE_ORDER) {
  const rows = Array.isArray(archive.tables?.[name]) ? archive.tables[name] : [];
  for (let i = 0; i < rows.length; i += ROWS_PER_REQUEST) {
    const page = rows.slice(i, i + ROWS_PER_REQUEST);
    const slice = { version: BACKUP_VERSION, tables: { ...emptyTables(), [name]: page }, images: [] };
    await postSlice(slice, `${name} [${i + 1}-${i + page.length}/${rows.length}]`);
    totalRows += page.length;
    console.log(`  ${name}: ${Math.min(i + page.length, rows.length)}/${rows.length} rows`);
  }
}

// 2. Images, paged.
const images = Array.isArray(archive.images) ? archive.images : [];
for (let i = 0; i < images.length; i += IMAGES_PER_REQUEST) {
  const page = images.slice(i, i + IMAGES_PER_REQUEST);
  const slice = { version: BACKUP_VERSION, tables: emptyTables(), images: page };
  const out = await postSlice(slice, `images [${i + 1}-${i + page.length}/${images.length}]`);
  totalImages += out.imageCount ?? page.length;
  console.log(`  images: ${Math.min(i + page.length, images.length)}/${images.length}`);
}

console.log(`Restored ${totalRows} rows · ${totalImages} images into ${base}`);
