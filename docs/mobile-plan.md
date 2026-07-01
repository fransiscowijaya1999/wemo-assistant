# Clerk Mobile App — Build Plan

The **clerk-facing** app: an offline-first Flutter Android app for the shop floor. It's a **read-only
replica** of the catalog — the clerk (and any AI feature in it) can look things up but **never
writes** to the backend (see the authorization invariant in `CLAUDE.md`). It evolves the existing
**Partie** app (keep its drift setup, image handling, UI patterns).

Build this on the **main PC** (needs the Android SDK). Everything it talks to is already built:
`docs/schema.md` (data model) and `docs/catalog-format.md` (domain) are the companions to this doc.

---

## 1. Architecture

```
Cloudflare backend (source of truth)          Clerk phone (this app)
GET /sync?since=<cursor>  ───────────────►     drift (SQLite) = local replica
GET /assemblies/:id/image ──────────────►     cached image files (app dir)
                                               offline: keyword + structured + visual lookup
                                               online: (future) AI fuzzy lookup
```

- **Offline-first.** All lookups run against the local drift DB + cached images. The network is used
  only to **sync** (pull deltas) and, later, for AI fuzzy lookup.
- **D1 is SQLite, drift is SQLite** — the replica mirrors the backend tables 1:1.

---

## 2. Prerequisite: a reachable backend URL

The app syncs from an HTTP URL. Options:
- **Deployed (recommended):** deploy the backend to Cloudflare Workers (`wrangler deploy`) → a stable
  `https://wemo-backend.<subdomain>.workers.dev`. Do this before real device testing.
- **Local dev:** run `wrangler dev --ip 0.0.0.0 --port 8787` and point the app at the PC's LAN IP
  (`http://<pc-ip>:8787`), or use a tunnel (`cloudflared`). Handy while iterating.

Make the base URL a **setting** in the app (stored locally), defaulting to the deployed URL.

> Auth: `/sync` and `/assemblies/:id/image` are currently open GETs (reads). Add a clerk token later;
> the app is read-only regardless.

---

## 3. Local drift schema (mirror the sync tables)

Mirror every table the sync API returns (all of `docs/schema.md` **except `users`**). D1↔drift are
both SQLite so types line up. Store `createdAt/updatedAt/deletedAt` as `DateTime` (the API sends them
as ISO strings; `DateTime.parse`). Keep text UUID PKs as `TEXT`.

Tables to mirror: `machines`, `machineVariants`, `colors`, `assemblies`, `assemblyItems`,
`itemResolutions`, `dots`, `assemblyLinks`, `parts`, `partNumbers`, `partColorVariants`, `aliases`,
`serviceItems`. Plus one **local-only** table for sync state.

Representative drift sketch (Dart):

```dart
class Parts extends Table {
  TextColumn get id => text()();
  TextColumn get nameRaw => text()();
  TextColumn get nameNormalized => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get specs => text().nullable()();          // JSON string
  TextColumn get notes => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override Set<Column> get primaryKey => {id};
}

class PartNumbers extends Table {
  TextColumn get id => text()();
  TextColumn get partId => text()();
  TextColumn get value => text()();                     // index this
  TextColumn get kind => text()();                      // oem|alternative|superseded|aftermarket|bulk
  TextColumn get brand => text().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override Set<Column> get primaryKey => {id};
}

class Dots extends Table {
  TextColumn get id => text()();
  TextColumn get assemblyItemId => text()();
  RealColumn get x => real()();                         // normalized 0..1 on the diagram image
  RealColumn get y => real()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  @override Set<Column> get primaryKey => {id};
}

// Local-only
class SyncState extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();  // single row
  IntColumn get cursor => integer().withDefault(const Constant(0))();  // ms epoch
  @override Set<Column> get primaryKey => {id};
}
```

Add indexes on `partNumbers.value`, `aliases.term`, `parts.nameNormalized`, `assemblyItems.assemblyId`,
`dots.assemblyItemId`, `partColorVariants.partId` (mirrors the backend indexes; these power lookups).

---

## 4. Sync flow

The endpoint is **paginated**: one session may span several requests. The client loops on
`hasMore`, feeding the returned `cursor` back verbatim, until the server signals completion — only
then does it advance its stored watermark.

```
1. token = SyncState.cursor  (0 or "" = full sync)
2. loop:
     GET {base}/sync?cursor={token}  ->  { since, cursor, hasMore, limit, tables }
     In ONE drift transaction, for each table in `tables`, for each row:
       if row.deletedAt != null   -> delete local row by id   (soft-delete propagation)
       else                       -> upsert (insertOnConflictUpdate)
     token = cursor
     if hasMore: continue loop        (same session; window is fixed server-side)
     else: break                      (delta complete)
3. Save token to SyncState.cursor.   // terminal `cursor` is a bare number = next `since`
4. Image sync: for every assembly seen in any page's `tables.assemblies` with imageRef != null,
   GET {base}/assemblies/{id}/image  -> write bytes to <appDir>/diagrams/{id}.img
   (only the assemblies present in this delta changed, so only they are refetched).
5. Show "last synced" + row counts.
```

Notes:
- Wrap each page's DB writes in one transaction. Pages are idempotent (upsert), so a retried page
  is harmless.
- **Pagination:** the server pulls a fixed window `since < updated_at <= newSince` per session and
  walks the tables with keyset paging (`ORDER BY updated_at, id`). While `hasMore` is true, `cursor`
  is an **opaque token** — pass it back unchanged, don't parse it or treat it as a timestamp. When
  `hasMore` is false, `cursor` is a **bare ms number** = the next session's low watermark; store
  that. `limit` (default 1000, max 5000) can be tuned per request but the client must still loop.
- Full resync = store cursor `0` (offer a "Force full sync" button as a recovery path).
- Timestamps in rows arrive as ISO strings; the terminal `cursor` is a number (ms) — store it
  verbatim, don't recompute.
- Use `dio` or `http`; set a sensible timeout; sync is the only network dependency for browsing.

---

## 5. Core offline queries (the whole point)

Implement these as drift queries — no network needed:

- **Any number → canonical part:** `partNumbers where value = ? and deletedAt is null` → `partId` →
  load `parts` + all its `partNumbers` + `partColorVariants`. (A superseded/aftermarket/NGK/Denso
  number all resolve to the one part.)
- **Vague term → candidates:** search `aliases.term` + `parts.nameNormalized` (LIKE / FTS). Add local
  synonyms over time. (Online AI fuzzy lookup is a later enhancement.)
- **Exact number for this bike:** part → `partColorVariants` for the bike's color → `fullNumber`
  (base+suffix); use `itemResolutions` (variant/serial) when the position is known.
- **Machine → assemblies → items:** `assemblies where machineId=?` grouped by `groupType`; per
  assembly, `assemblyItems` → `parts`.
- **Diagram view:** load `<appDir>/diagrams/{assemblyId}.img`; overlay `dots` for that assembly's
  items; tap a dot → its item's part; tap a part row → highlight its dots.

---

## 6. Diagram + dot rendering

Dots are normalized `0..1` relative to the **stored (cropped) diagram image** for the assembly.

- Put the image and dot markers in a `Stack` sized to the image; position each dot with `Positioned`
  at `x * width`, `y * height` (use `LayoutBuilder` to get the rendered size, or a fixed logical size
  inside a `FittedBox`).
- Wrap in `InteractiveViewer` for pinch-zoom/pan (keep dots as children of the transformed subtree so
  they move with the image).
- Marker = a small numbered circle (the item's `refNo`). Tapping selects the item → part detail.
- Reverse highlight: selecting a part row pulses its dot(s).

---

## 7. Screens (functional first; polish later)

1. **Search** — one box resolving number / name / alias → results → part detail. Recents/favorites.
2. **Browse** — machine picker → engine/frame groups → assembly grid (thumbnails) → diagram with dots.
3. **Part detail** — name, all numbers (with kind/brand + interchange), color variants (full numbers),
   which assemblies it appears in, service/FRT if relevant.
4. **Sync/Settings** — base URL, "Sync now", last-synced time, offline indicator, "Force full sync".

Big touch targets, fast, works one-handed with greasy hands. (Aesthetic polish deferred, per project
convention.)

---

## 8. Packages (build on Partie's)

- `drift` + `drift_flutter` (local DB) — already in Partie.
- `dio` (or `http`) for sync/image fetch.
- `path_provider` (app dir for cached images) — already in Partie.
- Flutter built-ins for UI: `Stack`/`Positioned`/`InteractiveViewer` for the diagram; `Image.file`
  for cached diagrams.
- (Later) an AI client for online fuzzy lookup — model-agnostic, mirroring the backend seam.

---

## 9. Suggested build order (mobile slices)

- **M1 — Replica + sync:** ✅ done. Fresh Flutter app at `apps/mobile` (`wemo_clerk`, feature-first
  `core/` + `features/sync/`). Drift schema mirrors all 13 sync tables + local `SyncState`; sync
  client walks the paginated `cursor`/`hasMore` loop (typed upserts + soft-delete propagation,
  cursor persisted per page); debug/sync screen shows base-URL setting, Sync now / Force full sync,
  and per-table row counts. Verified on the Android emulator (`emulator-5554`) against `wrangler
  dev` via an `integration_test`. Cleartext HTTP allowed only for local dev hosts.
- **M2 — Image sync + cache:** ✅ done. `ImageStore` caches one file per assembly at
  `<docs>/diagrams/<id>.img`; `SyncApi.fetchImage` + `ImageSyncService` fetch/remove images for the
  assemblies that changed in each delta (best-effort — image failures never fail the row sync). A
  Browse tab lists assemblies → `DiagramScreen` renders the cached image with normalized dots
  overlaid in an `InteractiveViewer` (pinch-zoom); tapping a dot shows the position's part (refNo,
  name, primary number). Verified on the emulator.
- **M3 — Lookup:** search box (number/name/alias) → part detail (numbers, interchange, color variants).
- **M4 — Visual browse:** machine → assembly → diagram with tappable dots (both directions).
- **M5 — Polish + online AI fuzzy lookup:** offline indicator, force-full-sync, then the online
  AI-assisted "describe the vague part" flow (needs a clerk-facing AI endpoint — future backend work).

---

## 10. Backend contract (what the app depends on)

- `GET /sync?since=<ms>&cursor=<token>&limit=<n>` → `{ since, cursor, hasMore, limit, tables: {
  <name>: Row[] } }`. Rows include `updatedAt` (ISO) and `deletedAt` (ISO|null). Paginated: loop
  while `hasMore`, passing `cursor` back verbatim (opaque mid-session); the terminal `cursor` is a
  bare ms number = the next `since`. `limit` defaults to 1000 (max 5000). `since` alone (no
  `cursor`) still works for a one-shot/first request.
- `GET /assemblies/:id/image` → image bytes (content-type set). Only assemblies with `imageRef`.
- Read-only; no auth yet. Base URL is a client setting.
- Table row shapes = `docs/schema.md`. `users` is **not** synced.

Keep the replica dumb and the backend authoritative: the phone never mutates catalog data.
