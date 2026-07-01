# Data Model

The canonical schema, implemented in `apps/backend/src/db/schema.ts` (Drizzle, D1/SQLite). It maps
directly onto `catalog-format.md`. D1 is SQLite — the **same engine as the clerk app's drift DB**, so
the mobile replica mirrors these tables.

## Entities

| Table | Purpose | Key fields |
|---|---|---|
| `machines` | A vehicle model | brand, model, type_code, k_code, engine/frame series, year range, catalog edition/date |
| `machine_variants` | Sub-variants of a machine | name (STD/ABS/CBS) |
| `colors` | Factory colors for a machine | code (NH-436M), name |
| `assemblies` | One exploded-diagram page | group (engine/frame), code (E-3), name, image_ref (R2 key), image_code, w/h, page_no |
| `assembly_items` | A **position** on a diagram | ref_no, base_part_id, note |
| `item_resolutions` | Which part number applies, when | part_number_id, qty, variant_id?, serial_from?, serial_to? |
| `dots` | Balloon coordinates for a position | x, y (0..1 normalized) — 1..N per position |
| `assembly_links` | Cross-refs to other assemblies | to_code (F-16), to_assembly_id?, x, y |
| `parts` | **Canonical** part (never duplicated) | name_raw, name_normalized, category, specs (json), notes |
| `part_numbers` | Numbers for a part | value, kind, brand, is_primary |
| `part_color_variants` | Per-color number for a part | color_id, suffix_code (ZE), full_number |
| `aliases` | Search synonyms / local terms | term, lang |
| `service_items` | Workshop labor times (FRT) | ref_no?, name, frt_hours |
| `users` | Auth | email, role (admin/clerk) |

Every syncable table also has `created_at`, `updated_at`, `deleted_at` (ms epoch; soft delete) for
delta sync.

## The position -> resolution model (why it's split)

A catalog **position** is "balloon N on diagram X". A position does not map to a single part number —
it resolves to one depending on the bike's **variant** and **frame serial range**, and the number is
further specialized by **color**. So:

```
assembly_items (position: assembly + ref_no + base part)
   └── item_resolutions (part_number + qty, filtered by variant + serial_from/to)
   └── dots (one or more balloon coordinates)
parts ──< part_numbers                (interchangeable numbers on one canonical part)
parts ──< part_color_variants ── colors   (base + color suffix = full number)
```

This one structure covers every case seen in the catalogs:
- **Interchange** (NGK/Denso plugs): one `parts` row, two `part_numbers` (kind `alternative`).
- **Serial cutoff**: two `item_resolutions` with different `serial_from/to`.
- **STD/ABS quantities**: `item_resolutions` differing by `variant_id` + `qty`.
- **Color**: `part_color_variants` supplies the suffix/full number for the customer's color.

## Interchange / merge policy

Parts are canonical and **never duplicated**. Interchangeable/superseded/aftermarket numbers are rows
in `part_numbers` (`kind` in `oem | alternative | superseded | aftermarket | bulk`, with optional
`brand`). AI **suggests** merges during ingestion; a human **verifies** before merging. Search indexes
**every** `part_numbers.value`, so any number a customer brings resolves to the canonical part and all
its equivalents.

## Key query flows

- **Any number -> the part:** lookup `part_numbers.value` (indexed) -> `part_id` -> all numbers + placements.
- **Vague term -> candidates:** search `aliases.term` / `parts.name_normalized` (offline keyword);
  online adds semantic search over embeddings.
- **Exact part for this bike:** `assembly_item` (position) -> `item_resolutions` filtered by the
  machine's `variant` + frame serial -> `part_number`; if colored, apply `part_color_variants` for the
  bike's color.
- **Diagram interaction:** tap a dot -> its `assembly_item` -> part detail; tap a part -> highlight its
  `dots`.

## Server-only

`part_embeddings` (pgvector/Vectorize or cosine-over-blob in D1) powers online fuzzy lookup. The
clerk phone does **not** replicate embeddings — offline it falls back to keyword + visual browsing.
