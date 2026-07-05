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
apps/mobile/      Flutter clerk app (wemo_clerk) — offline drift replica + sync (main PC)
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
- [x] Slice 11: sync hardening — `updated_at` indexes on all syncable tables + keyset pagination (`?cursor=&limit=`, bounded window, `hasMore`) so a whole-catalog replica pulls in bounded pages.
- [x] Mobile M1: clerk app scaffold (`apps/mobile`, fresh Flutter+drift, Partie as reference only) — replica of all 13 sync tables + local `SyncState`, paginated sync client (upsert/delete/cursor), debug/sync screen with per-table counts. Verified on the Android emulator against the backend.
- [x] Mobile M2: diagram image sync + cache (`ImageStore`, `ImageSyncService`) + Browse tab → `DiagramScreen` rendering the cached image with tappable normalized dots (InteractiveViewer). Verified on the emulator.
- [x] Mobile M3: offline lookup — `LookupRepository` (any number/name/alias → canonical part), `SearchScreen` (debounced) → `PartDetailScreen` (numbers + interchange, color variants, aliases, "appears in" → diagram with dot highlighted). Shell now Browse/Search/Assistant/Sync. Verified on the emulator.
- [x] Clerk AI assistant: `POST /chat` — **read-only** clerk-facing chat (model-agnostic `ChatProvider` seam; providers: Claude, **DeepSeek** (OpenAI-compatible), keyless `AI_CHAT=stub`; selected via `CHAT_PROVIDER` or auto-detected by key; only read tools `search_parts`/`get_part`, no mutations) + mobile Assistant tab (chat, offline banner, citation chips → part detail). Verified on the emulator with the stub; real answers need a provider key.
- [x] Slice 12: serial/variant applicability — extraction captures the 2024 `No. Seri` + per-variant `Jumlah` columns (`serialFrom/serialTo`, `variantQtys`, `variantColumns`); commit get-or-creates `machine_variants` and fans out one `item_resolutions` row per number×variant (variant NULL = all; commit now **replaces** a live assembly with the same machine+code via soft-delete cascade); reads surface + filter it (`/assemblies/:id/full?variantId=&serial=`, `/parts` placements, `GET/POST /machines/:id/variants`, chat `get_part` applicability; serial compare in `src/lib/serial.ts`); admin review edits s/n + per-variant qty, Browse filters by variant/serial with "Applies to" badges. Verified end-to-end on PCX160 2024 p.58 (CBS/ABS meter split) + BeAT 2008 regression.
- [x] Admin UI polish: custom Mantine theme (`wemo` amber primary) + AppShell header (brand, machine select, dark-mode toggle) + tab icons + favicon; `@mantine/notifications` toasts replace per-view msg/err strings; Ingest is a two-step card flow with a drag-drop target; Batch gains empty state + progress bar + per-page status icons; Browse is carded with a stat strip, skeletons, per-section errors, structured lookup results and empty states; Settings uses PasswordInput + "Test connection" against new `GET /auth/check` (requireAdmin); machine/tab persisted in localStorage. Verified light+dark via headless-Edge screenshots.
- [x] Admin UX follow-ups: Browse renders the assembly diagram with read-only numbered dots; part search is fuzzy — `GET /parts/search?q=` (shared `searchParts` engine, now dash-insensitive/partial for numbers) with a pick-one candidate list in the UI; **runtime AI config** — `app_settings` D1 table (server-only, NOT synced) + `GET/PUT /settings/ai` (admin) override env secrets for chat provider/model + Anthropic/DeepSeek keys, editable from Settings → AI provider (chat/vision status badges). `resolveAiConfig` (DB ?? env) feeds both factories.
- [x] Mobile M4: visual browse — Browse tab is now a machine list (`MachineListScreen`, per-machine diagram counts) → `MachineBrowseScreen` (Engine/Frame segmented toggle over a thumbnail grid of cached diagrams, catalog-numeric code order) → existing `DiagramScreen`. Verified on the emulator (sync → machine → grid → diagram dot).
- [x] Mobile M5: offline/sync polish — `ConnectivityController` (30s `GET /health` probe + on-resume), app-wide offline strip above the nav bar ("Offline — using local catalog, synced Xm ago", tap = retry), auto delta-sync when the backend becomes reachable and the replica is >15 min stale. Verified on the emulator (launch auto-sync, strip on backend death, tap-retry recovery).
- [x] Mobile M6: variant/serial picker — Dart port of backend `serial.ts` (`core/util/serial.dart`), session-scoped `FitmentController` (per-machine variant + optional frame serial, not persisted), fitment bottom sheet (variant chips + serial field) opened from a chip on `MachineBrowseScreen` and a badged filter action + "Showing parts for …" banner on `DiagramScreen` (both only shown when the machine has variants or serial-ranged resolutions); diagram dots resolve through `item_resolutions` — positions that don't apply to the fitment dim grey, the tap card shows the resolved number(s) + qty + applicability labels (or "Not used on <fitment>"), and part-detail "Appears in" rows gain a "Fits: …" line. Verified on the emulator (seeded BeAT ABS/STD + serial-range splits; gotcha: the theme's full-width `FilledButton` minimumSize silently breaks layout inside a `Row`).
- [x] Batch-ingest hardening (found running the PCX160 catalog): vision extraction now **streams** (non-streaming only returns headers when generation finishes, so long-thinking pages hung until HTTP timeout); extraction schema **requires** the diagram bbox ({0,0,1,1} = whole page); pdf.js gets `wasmUrl` (catalog diagrams are JBIG2 stencils — without the wasm decoders pdf.js silently renders a blank diagram region, giving white crops + zero dots; `scripts/copy-pdfjs-wasm.mjs` populates `public/pdfjs-wasm` before dev/build); batch "Extract selected" re-runs only pending/error pages.
- [x] Mobile M7 (clerk polish 1/4, search): offline search now mirrors the backend engine — token search (parts ranked by how many query words match any field) + dash-insensitive/partial part numbers ("12251KVY" finds 12251-KVY-900); result rows show why-it-matched (matched number or alias) and the machines the part appears on; empty search state lists recently viewed parts (`RecentPartsStore`, shared_preferences MRU, recorded on every PartDetailScreen open, Clear button). Verified on the emulator (dash-less number, "paking beat" alias+token, recent list).
- [x] Mobile M8 (clerk polish 2/4, diagram): parts-list bottom sheet on `DiagramScreen` (positions in ref order, resolved numbers per fitment, tap = select + zoom to dot); `DiagramView` gains programmatic focus (focusDot/focusTick — used by the sheet and by arrive-from-part-detail highlight, which now auto-zooms) and 44px dot hit targets; selected-dot card taps through to `PartDetailScreen` ("Tap for full detail"); thin prev/next strip flips between the machine's assemblies in grid order (hidden while a card is open). Verified on the emulator (highlight auto-zoom, sheet select, card→detail, 1/2↔2/2 flip incl. imageless assembly).
- [x] Mobile M9 (clerk polish 3/4, assistant): empty state gains tappable suggested prompts (realistic Indonesian shop asks, tap = send); error bubbles get an in-place Retry that re-sends the same history (trailing error bubbles dropped, no retyping); offline UX now driven by the app-wide `ConnectivityController` (banner + disabled input recover automatically when the backend returns — `AssistantController` no longer keeps its own one-shot probe); thinking bubble says "Looking up the catalog…". Verified on the emulator with the stub provider (chip send + citation, offline banner/disabled input on backend death, 503 error bubble → Retry → answer).
- [x] Mobile M10 (clerk polish 4/4, look & feel): brand aligned with the admin web — theme seeded from wemo amber `#FD7E14` (Mantine orange[6]) + dark theme (`ThemeMode.system`); launcher icon + adaptive icon (amber, white "W"; source PNGs generated into `assets/icon`, regenerate via `dart run flutter_launcher_icons`) + native splash (`dart run flutter_native_splash:create`); app label "Wemo Clerk". Verified on the emulator (splash, drawer icon/label, amber theme; recents survive reinstall). No i18n — user opted out of UI localization.
- [x] Clerk read auth: `CLERK_TOKEN` binding + `requireClerkRead` guards `GET /sync` and `POST /chat` (admin token also accepted; missing token denies by default; `GET /auth/clerk-check` probe; `/health` and image GET stay open — admin `<img src>` can't send headers, image URLs are unguessable UUIDs only discoverable via the guarded /sync). Mobile: "API key" field on the Sync screen (shared_preferences, obscured with show/hide — entered by hand, nothing compiled into the APK), Bearer header on sync/image/chat requests, friendly 401 messages. Local dev key in `.dev.vars` (`CLERK_TOKEN=dev-clerk-key`); set a `wrangler secret put CLERK_TOKEN` in prod. Verified on the emulator (no key → "Not authorized" banner, key → sync + stub chat OK).
- [x] Multi-page-assembly merge (found mapping the PCX160 catalog: many assemblies span several pages sharing one code — e.g. **F-12 FRONT COVER = p74 diagram+refs 1–7, p75 same diagram+refs 7–11, p76 table-only refs 11–26**). Commit no longer replaces the whole assembly by `(machineId, code)`; it **get-or-creates the assembly and upserts positions by ref number** (`ingest-persist.ts`) — continuation pages merge in, a re-committed page refreshes only its own refs, and page 1's `imageCode`/FRT survive a later page that lacks them. Client `autoMap` (`ingest-helpers.ts`): only runs when the page carries a diagram (`pageHasDiagram`: balloon dots or a sub-page bbox); the **first** diagram page owns the R2 image (later pages of the same assembly keep it, so cross-page dots stay on one picture); and dots are **merged** — positions from other pages are re-sent because `PUT /dots` overwrites the whole assembly. Verified end-to-end against local D1 (two-page merge keeps refs 1–4 + imageCode + FRT; re-run of page 1 refreshes its position qty without disturbing the continuation). Extraction prompt also hardened for **table-only continuation pages** (a parts table with no drawing, e.g. F-12 p76): Sonnet 5 was returning zero items ("no diagram → nothing to extract"), so the prompt now leads with a parts-table-first MUST — verified p76 → 16 items (refs 11–26). A continued row keeps its printed ref (e.g. `11)`) so it commits as its own position rather than clobbering the earlier `11`.
- [x] Color-review UI (`apps/admin/src/ColorIngestView.tsx`, **Color index** tab): mirrors the assembly `IngestView` — upload a color-index page → extract via `/ingest/color-page` → review the color legend + a base-number×color **suffix matrix** (empty cell = not offered in that color) → commit via `/ingest/color-commit`. Previously colors could only be committed blind through Batch.
- [x] Admin correction assistant (safe edits) — admin-only AI chat that **drafts** catalog corrections for approval; it never writes directly. `POST /admin/chat` (`requireAdmin`) reuses the model-agnostic `ChatProvider` loop with `createAdminToolset` (`ai/admin-tools.ts`): read tools (`search_parts`/`get_part`) + `propose_*` tools (rename/normalize, add alias, add number, edit number) that only **record structured proposals** with a before/after snapshot — mirroring the clerk toolset's citation collector. Writes happen solely in `POST /admin/corrections/apply` when the admin approves one (`services/corrections.ts` — zod discriminated union + `applyCorrection` with dup/liveness guards), keeping "never auto-change, human verifies" on the write-capable side. Admin **Assistant** tab (`AssistantView.tsx`): chat + proposal cards (before→after diff + Approve/Reject). Verified against local D1 (apply lands rename/alias, dup + cross-part-number guards 409, no-auth 401; a real Claude turn drafted a clean rename for 31916-KRM-841 end-to-end).
- [x] Assistant catalog-enumeration tools — the chat could not list what the catalog contains, so it answered "what machines/assemblies do I have" by guessing from part searches (once wrongly reporting PCX160 absent, and "klep"=valve missing when PCX160 E-4 has VALVE IN/EX). Added `list_machines`, `list_assemblies`, `get_assembly` (parts in an assembly, by id or machine+code) to **both** the clerk and admin toolsets (`ai/catalog-tools.ts`), and told the admin assistant to use them, translate Indonesian everyday terms (klep=valve, paking=gasket, seher=piston, laher=bearing), and never assert a part/model absent without opening the relevant assembly. Verified end-to-end on local D1.
- [x] Correction assistant slice 2 — **part merge/dedup**. `propose_merge` (source→target) drafts a merge of two duplicate canonical parts; on approval `applyCorrection` reparents `part_numbers` (deduped by value, moved numbers demoted so target keeps one primary), `aliases` (deduped by term; source's name kept as a searchable alias on the target), `part_color_variants` (deduped by color), and `assembly_items.basePartId` src→dst, then soft-deletes the source (tombstone syncs). Still proposal-only. Merge proposal card renders source→target + move counts, styled as destructive. Verified against local D1 with a seeded fixture (unique number moved+demoted, dup number deduped, alias moved, source name→alias, position repointed, source tombstoned; self-merge 409; a real Claude turn drafted a correct merge honoring the requested keeper). Also fixed: admin Assistant tab is `keepMounted` so chat + proposals survive tab switches.
- [x] Catalog backup / restore — snapshot the whole catalog from one deployment and replay it into another over HTTP, so token-expensive AI ingest done in **dev** isn't lost when moving to prod (no re-extraction). `services/backup.ts`: `GET /admin/backup` streams one JSON archive (the **13 catalog tables** + every referenced **R2 diagram image** as base64; excludes `app_settings` (AI secrets) + `users` (auth)); `POST /admin/restore` idempotently upserts rows by PK (`ON CONFLICT DO UPDATE` via `excluded`, FK-parent-first order, chunked under D1's 100-bound-param cap) + R2 puts. Both `requireAdmin`. CLI: `bun run backup` → `apps/backend/backups/wemo-<ts>.json` (gitignored), `ADMIN_TOKEN=<prod> bun run restore <file> <prod-url>` (scripts default to `127.0.0.1` — Node `fetch` prefers IPv6 `::1` which wrangler dev doesn't bind on Windows). Verified against local D1 (28 rows + 1 image roundtrip with no duplication → excluded-upsert, Date↔ms serialization + image roundtrip all sound; 401 no-token, 400 bad archive). Admin Settings Download/Restore **buttons deferred** to a follow-up slice.
- [x] Mobile M11 (search assemblies): the Search tab finds **diagrams/assemblies**, not just parts — `LookupRepository.searchAssemblies` reuses the token-scoring engine (ranks by how many query words match assembly code/name or machine brand/model, so "beat cylinder head" works). Results render in two sections (**Diagrams** then **Parts**, section headers only when both present, so the parts-only case is unchanged); assembly tiles (`E-4 · Cylinder Head` / `Honda PCX160 · N parts`, image-vs-table-only icon) open `DiagramScreen`. `dart analyze` clean; needs an emulator pass.
- [x] Assistant cites diagrams — the clerk assistant can now link to **assemblies**, not just parts. Backend `Citation` is a discriminated union (`type:"part"` | `type:"assembly"`); the catalog toolset tags part citations and collects an assembly citation from every `get_assembly` the model runs (`get_assembly` returns its `assemblyId` + an explicit `GetAssemblyResult` type so the `in`-narrowing is clean); the keyless stub opens a diagram when the query names an assembly code, so the path is verifiable without a key. Mobile: `ChatCitation` is a `sealed` class (`PartCitation` | `AssemblyCitation`, `fromJson` dispatches on `type`, missing type ⇒ part); new `_CitationChip` switches on it — part chips → `PartDetailScreen`, assembly chips → `DiagramScreen`. Verified end-to-end against local D1 with a real Claude turn (assembly query → `type:"assembly"` citation, part-number query → `type:"part"`).
- [x] Substitute parts (manual interchange links) — a hand-entered, **symmetric** link between two DIFFERENT canonical parts that can replace each other (e.g. 12000-KWB ↔ 12000-KYZ). Distinct from `part_numbers` (same physical part, several printed numbers) and from a merge (destructive dedup); AI ingest can't know shop-level interchange, so it's admin-only manual. Backend: `part_substitutes` table (one undirected row per pair, canonically ordered by id string), `getPartFull` returns a `substitutes[]` (unions both columns → other side + primary number + note), `POST /parts/:id/substitutes` + `DELETE /parts/:id/substitutes/:otherId` (`requireAdmin`; self-link 400, dead part 404, dup either-direction 409), synced to the clerk replica + included in backup. Admin: new **Substitutes** tab (`SubstitutesView.tsx`) — pick a part (fuzzy `PartPicker`) → removable teal chips for current substitutes → add another part + optional note; Browse part detail surfaces them read-only. Verified end-to-end against local D1 via headless Edge (link 12251-KRM-872 ↔ 12251-KVY-901, reverse side lists it back, remove → zero). Still TODO: a `propose_substitute` tool so the admin correction assistant can draft interchange links for approval.
- [ ] Next: correction-assistant `propose_substitute`; backup/restore admin UI buttons; semantic lookup; multi-brand/web-source adapter; bundle code-split.
