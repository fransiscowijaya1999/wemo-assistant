#!/usr/bin/env node
// Replay a backup JSON into a deployment's D1 + R2 (idempotent upsert).
//
//   bun run restore backups/wemo-….json                      # into local dev
//   ADMIN_TOKEN=<prod> bun run restore backups/wemo-….json https://prod
import { readFile } from 'node:fs/promises';

const file = process.argv[2];
if (!file) {
  console.error('Usage: bun run restore <backup.json> [url]   (token via ADMIN_TOKEN env)');
  process.exit(1);
}
// 127.0.0.1 (not "localhost") — Node's fetch prefers IPv6 ::1, which wrangler dev doesn't bind on Windows.
const base = (process.argv[3] || process.env.RESTORE_URL || 'http://127.0.0.1:8787').replace(/\/$/, '');
const token = process.env.ADMIN_TOKEN || 'dev-admin-key';

const body = await readFile(file, 'utf8');
const res = await fetch(`${base}/admin/restore`, {
  method: 'POST',
  headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
  body,
});

const out = await res.json().catch(() => ({}));
if (!res.ok) {
  console.error(`Restore failed: ${res.status} ${res.statusText}`, out);
  process.exit(1);
}

const rows = Object.values(out.counts || {}).reduce((a, b) => a + b, 0);
console.log(`Restored ${rows} rows · ${out.imageCount} images into ${base}`);
