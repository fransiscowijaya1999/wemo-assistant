# wemo-assistant

A parts-identification assistant for a motorcycle **spare-part shop + workshop**. It helps the shop
find the **correct part for a specific machine** from OEM parts catalogs — even when the customer
brings no part number — via a browsable, searchable, dot-mapped catalog with AI-assisted lookup.

See **[CLAUDE.md](./CLAUDE.md)** for the full picture. Key docs:

- **[DEPLOYMENT.md](./DEPLOYMENT.md)** — how to deploy all three apps (backend, admin, mobile) to production, step by step.
- **[docs/catalog-format.md](./docs/catalog-format.md)** — how Honda parts catalogs are structured (the source data).
- **[docs/schema.md](./docs/schema.md)** — the data model and why it looks the way it does.
- **[docs/mobile-plan.md](./docs/mobile-plan.md)** — build plan for the Flutter clerk app.

## Components

| Part | Stack | Location | Runs on |
|---|---|---|---|
| Backend + API (source of truth) | Hono + Cloudflare Workers + D1 + R2 | `apps/backend` | this PC |
| Admin web (rich editing + AI ingestion) | Vite + React (planned) | `apps/admin` | this PC |
| Clerk mobile (offline lookup) | Flutter + drift (planned; evolves *Partie*) | `apps/mobile` | main PC (needs Android SDK) |

## Quick start (backend)

```bash
cd apps/backend
bun install
bun run typecheck
bun run db:generate      # generate SQL migrations from the Drizzle schema
# Cloudflare resources (needs `wrangler login`):
#   wrangler d1 create wemo        -> paste database_id into wrangler.jsonc
#   wrangler r2 bucket create wemo-catalog-images
bun run dev
```

## Backup / restore

Snapshot the whole catalog from one deployment and replay it into another over HTTP — so the
token-expensive AI ingest done in **dev** isn't lost when moving to **prod** (no re-extraction). One
JSON archive holds the 14 catalog tables + every referenced R2 diagram image (base64); it excludes
`app_settings` (AI secrets) and `users` (auth). Both routes are `requireAdmin`. Full write-up (what's
in it, idempotency, caveats) in **[DEPLOYMENT.md](./DEPLOYMENT.md)** §1e.

```bash
cd apps/backend

# Backup — writes ./backups/wemo-<timestamp>.json (gitignored)
bun run backup                                          # local dev (127.0.0.1:8787, dev-admin-key)
ADMIN_TOKEN=<prod-token> bun run backup https://prod    # a specific deployment

# Restore — idempotent upsert by primary key (safe to re-run)
bun run restore backups/wemo-<timestamp>.json                                 # into local dev
ADMIN_TOKEN=<prod-token> bun run restore backups/wemo-<timestamp>.json https://prod
```

The dev server (`bun run dev`) must be running for the local commands. Scripts default to `127.0.0.1`
(not `localhost`) because Node's fetch prefers IPv6 `::1`, which wrangler dev doesn't bind on Windows.
