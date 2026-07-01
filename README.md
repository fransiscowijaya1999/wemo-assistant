# wemo-assistant

A parts-identification assistant for a motorcycle **spare-part shop + workshop**. It helps the shop
find the **correct part for a specific machine** from OEM parts catalogs — even when the customer
brings no part number — via a browsable, searchable, dot-mapped catalog with AI-assisted lookup.

See **[CLAUDE.md](./CLAUDE.md)** for the full picture. Key docs:

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
