# CLAUDE.md

Guidance for working in this repo.

## What this is

A parts-identification assistant for a **motorcycle spare-part shop with an attached workshop**
(engineering/machinery domain, Indonesia). Customers are frequently non-technical and arrive
**without a part number** (the broken part has no visible marking, or they can't describe it). The
core problem the app solves: **identify the exact correct part for a specific machine**, surfacing
the OEM parts catalog for that machine.

First feature: browse/search a machine's parts catalog with **dot-mapped exploded diagrams**
(balloon callouts on the diagram linked to the parts list), plus AI-assisted fuzzy lookup for the
vague cases. The source data is Honda Indonesia parts catalogs (see `docs/catalog-format.md`).

## Users & roles

- **Admin (shop owner):** read + write. Ingests/edits catalog data. Uses the **web** app (and can
  also log into mobile).
- **Clerk:** **read-only** lookup via the app. Cannot modify data. Uses the **Android** app.
- Separate phones; **unreliable internet** at the shop → offline-first on the clerk side.

**Authorization invariant (load-bearing):** the clerk app has **no mutation paths at all** — not via
the UI and not via AI. Any AI feature on the clerk side may only **read/fetch** (look up, summarize,
explain); it must never create/update/delete. All writes are **admin-only**, authenticated, and go
through the backend. The clerk's local drift DB is a read replica that never writes back to the
master. Enforced in the backend by `requireAdmin` on every mutation route.

## Architecture

```
Backend + Admin (source of truth)            Clerk mobile (offline replica)
Cloudflare Workers/D1/R2                      Flutter + drift (SQLite)
  - master catalog (D1 = SQLite)      sync    - offline browse + keyword/visual lookup
  - AI ingestion (catalog page -> data) --->  - online: AI-assisted fuzzy lookup via API
  - images in R2                              - pulls catalog deltas when online
  - sync API + auth (admin/clerk)
```

- **Sync model:** small backend is source of truth; clerk phones **pull deltas when online**, work
  fully offline otherwise. Every syncable row has `updated_at` + `deleted_at` (soft delete); the
  phone keeps a cursor and pulls changes since last sync. Images downloaded on change.
- **Offline chat:** online = full AI lookup; offline = local keyword + visual browsing (no
  generated answer). AI is only for the redundant/complex cases, not every lookup.

## Stack

- **Backend/API:** Hono on Cloudflare Workers. DB: **D1 (SQLite)** + **Drizzle ORM**. Images: **R2**.
  Semantic search: **Vectorize** or cosine over embeddings in D1 (small dataset). Auth: **better-auth** (planned).
- **Admin web:** Vite + React SPA on Cloudflare Pages (internal tool, no SSR needed) — planned.
- **Clerk mobile:** Flutter + drift; **evolves the existing `Partie` app** (keep drift, image-map UI, archive). Built on the main PC (Android SDK not installed here).
- **Toolchain:** Bun (local dev/package manager). Production runtime is workerd — avoid Bun-only runtime APIs in shipped Worker code.
- **AI is model-agnostic:** all AI calls go through provider interfaces (`VisionExtractionProvider`,
  `ChatProvider`, `EmbeddingProvider`) so OpenAI/Gemini/Claude/local are swappable by config.

## AI does the tedious work (the point of the admin side)

Building the catalog by hand (crop image, place dots, type rows) is the bottleneck. AI ingestion,
per catalog page: OCR the parts table -> rows; detect balloon callouts -> dot (x,y); read the FRT
table -> service items; normalize names + suggest aliases and **interchange merges** for the admin
to approve. Never auto-merge — human verifies.

## Repo layout

```
apps/backend/     Hono + D1 + Drizzle (this PC)
apps/admin/       Vite + React admin — extract/review/commit UI (this PC)
apps/mobile/      Flutter clerk app (planned, main PC)
docs/             catalog-format.md, schema.md, mobile-plan.md
```

## Development workflow

Build in **reviewed vertical slices**: plan -> implement -> user verifies it runs -> commit -> next.
Do **not** run an autonomous agent over the whole thing. Keep each slice compiling/working and
committed before moving on. The two halves split across machines: backend + admin here (Node/Bun
only), Flutter mobile on the main PC.

## Backend commands (`apps/backend`)

```bash
bun install
bun run typecheck            # tsc --noEmit
bun run db:generate          # drizzle-kit generate -> ./drizzle SQL migrations
bun run db:migrate:local     # apply migrations to local D1
bun run db:migrate:remote    # apply migrations to remote D1
bun run dev                  # wrangler dev
bun run deploy               # wrangler deploy
```

One-time Cloudflare setup (interactive — run yourself): `wrangler login`, then
`wrangler d1 create wemo` (paste the `database_id` into `wrangler.jsonc`) and
`wrangler r2 bucket create wemo-catalog-images`.

## Conventions

- **IDs:** text UUID primary keys (`crypto.randomUUID()`), generated app-side — safe for offline
  creation and sync.
- **Timestamps/sync:** every syncable table has `created_at`, `updated_at`, `deleted_at` (ms epoch).
- **Data model:** parts are **canonical and never duplicated**; interchangeable numbers live in
  `part_numbers` on one part. A catalog **position** (`assembly_items`) resolves to a part number via
  `item_resolutions`, filtered by variant + serial range; color suffix via `part_color_variants`.
  See `docs/schema.md`.

## Status

- [x] Slice 0: repo + docs + backend scaffold (Hono/D1/Drizzle schema).
- [x] Slice 1: data plane — local D1 + machines/assemblies read+write endpoints (admin-guarded).
- [x] Slice 2: AI catalog-page extraction — POST /ingest/page (Claude, model-agnostic seam).
- [x] Slice 3: persist reviewed drafts — POST /ingest/commit (part dedup/merge) + GET /assemblies/:id/full.
- [x] Slice 4: color/variant ingestion — POST /ingest/color-page + /color-commit; GET /parts?number=… (resolve any number) + /parts/:id.
- [x] Slice 5: admin web UI (Vite+React, apps/admin) — machine select/create, upload page, extract -> editable review -> commit.
- [x] Slice 6: dot mapping — R2 image storage + balloon dots (POST/GET image, PUT dots) + admin diagram/dot editor.
- [x] Slice 7: AI auto-crop diagram + auto-place balloon dots at ingest (extraction returns diagram bbox + per-ref coords; admin crops client-side, transforms + saves dots).
- [x] Slice 8: whole-catalog batch ingest — admin renders the PDF (pdf.js), per-page type select, concurrency-limited extract, bulk commit (group inferred from code, dedup/merge, auto-crop + dots).
- [x] Slice 9: admin UI cleanup — Mantine + tabs (Ingest/Batch/Dot mapping/Browse/Settings); Browse view (assemblies + lookup part by any number).
- [x] Slice 10: delta sync API — GET /sync?since=<ms> returns changed rows (incl. soft-deletes) + cursor, for the offline clerk replica.
- [ ] Later: clerk mobile (Flutter, main PC), serial/variant applicability, color-review UI, semantic lookup, multi-brand/web-source adapter, sync pagination + updatedAt indexes, bundle code-split.
