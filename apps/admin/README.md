# @wemo/admin

The **admin** web app — the shop owner's tool for ingesting and editing the catalog (AI extraction,
dot mapping, corrections, substitutes). Vite + React SPA, deployed to Cloudflare Pages. Write access
is gated by a shared `ADMIN_TOKEN` entered in **Settings** (see the auth model in the repo `CLAUDE.md`).

## Local dev

```bash
cd apps/admin
bun install
bun run dev        # http://localhost:5173 ; /api/* is proxied to the backend on :8787 (vite.config.ts)
```

Run the backend (`apps/backend`, `bun run dev`) alongside it. Then open **Settings**, paste the local
`ADMIN_TOKEN` (`dev-admin-key` from `apps/backend/.dev.vars`), and **Test connection**.

## Scripts

- `bun run dev` — Vite dev server (copies pdf.js wasm first).
- `bun run build` — type-check + production build to `dist/`.
- `bun run typecheck` — `tsc --noEmit`.

## Deploy

See the repo-root **[DEPLOYMENT.md](../../DEPLOYMENT.md)** (§2) — build `dist`, deploy to Cloudflare
Pages, and add the small `functions/api/[[path]].js` proxy so `/api/*` reaches the backend Worker
same-origin (no CORS). First login: paste `ADMIN_TOKEN` into Settings.
