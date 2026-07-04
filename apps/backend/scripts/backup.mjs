#!/usr/bin/env node
// Download a full catalog backup (D1 rows + R2 images) to ./backups/.
//
//   bun run backup                         # local dev (http://localhost:8787, dev-admin-key)
//   BACKUP_URL=https://prod ADMIN_TOKEN=… bun run backup
//   bun run backup https://prod            # url as arg; token still from ADMIN_TOKEN
import { mkdir, writeFile } from 'node:fs/promises';
import { join } from 'node:path';

// 127.0.0.1 (not "localhost") — Node's fetch prefers IPv6 ::1, which wrangler dev doesn't bind on Windows.
const base = (process.env.BACKUP_URL || process.argv[2] || 'http://127.0.0.1:8787').replace(/\/$/, '');
const token = process.env.ADMIN_TOKEN || 'dev-admin-key';

const res = await fetch(`${base}/admin/backup`, { headers: { Authorization: `Bearer ${token}` } });
if (!res.ok) {
  console.error(`Backup failed: ${res.status} ${res.statusText}\n${await res.text()}`);
  process.exit(1);
}

const text = await res.text();
const archive = JSON.parse(text);
const dir = join(process.cwd(), 'backups');
await mkdir(dir, { recursive: true });
const stamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
const file = join(dir, `wemo-${stamp}.json`);
await writeFile(file, text);

const rows = Object.values(archive.counts).reduce((a, b) => a + b, 0);
console.log(`Saved ${file}`);
console.log(`  ${rows} rows across ${Object.keys(archive.counts).length} tables · ${archive.imageCount} images · from ${base}`);
