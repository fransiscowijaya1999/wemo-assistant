# Honda Parts Catalog Format

Reference analysis of the source data, so we don't re-derive it from PDFs each time. Based on
Honda Indonesia (AHM) *Katalog Suku Cadang* PDFs, cross-checked across an old edition
(**BeAT, 2008**) and a current one (**PCX160, 2024**). The core structure is stable across 16 years;
the 2024 edition adds relational layers (color/variant/serial applicability).

## Document structure (in order)

1. **Front matter** — usage guide, part-number anatomy, color codes, abbreviations, dimension
   conventions, FRT (Flat Rate Time) explanation, and the machine's model/series identity table
   (type code, market, engine series, frame series). 2024 also documents **revision/serial ranges**
   and L/R conventions.
2. **Group index grids** — one page per group with a 3x3 grid of assembly thumbnails. Groups:
   **MESIN** (Engine, codes `E-*`) and **RANGKA** (Frame, codes `F-*`). Each cell = `code + name +
   image_code` (e.g. `E-3 CYLINDER HEAD`, image `KVYIE0300` / `K1ZSE0300`).
3. **Assembly detail pages** — the core (see below). One per assembly.
4. **Color index** (2024) — colored parts mapped to color-specific suffix codes and to their
   diagram location. See "Color-variant matrix".
5. **Standard/bulk parts reference** — dimensional tables for generic parts (vinyl tube, bolts,
   o-rings), with bulk/roll ("borongan") numbers.

## Assembly detail page (the core)

Layout: assembly `code` + `name` (e.g. `E-3 Cylinder Head`), an **exploded diagram** with numbered
**balloon callouts**, an internal `image_code` (e.g. `KVYIE0300`), and **two tables**:

- **Parts table** — columns: `No.` (= balloon/ref number) | `Part Number` | `Description` | `QTY`
  | `Notes`. In 2024, also inline `No. Seri` (serial range) and per-variant `Jumlah` (qty) columns.
- **Service / F.R.T. table** — flat-rate **labor hours** per service item (e.g. `HEAD, CYLINDER 2.7`,
  `PLUG, SPARK 0.2`). Useful for the **workshop** side (labor quoting).

### Structural rules that shape the schema

- **One ref number -> many dots, one parts row.** A ref like `14` (NUT, QTY 4) appears as several
  balloons on the diagram but a single table row. So a position has 1..N dot coordinates.
- **Alternates under one ref number.** A ref can list multiple interchangeable part numbers. Real
  example (BeAT `E-3`, No. 12): `31916-KRM-841 PLUG, SPARK (CPR8EA-9)` **and**
  `31928-MFF-D01 (U24EPR9)` — NGK and Denso equivalents. This is why parts are **canonical with a
  list of numbers**, never duplicated.
- **Cross-references to other assemblies.** Diagrams point at neighbors (`F-16`, `F-17-1`) where the
  parts continue.
- **Supersession.** A part number placed under a name in `Description` indicates the old number was
  replaced (supersedence), sometimes with a serial cutoff.

## Color-variant matrix (2024)

The same base part gets a **different full part number per bike color**. The color index lists:
`No.` | colored part name | **base part number** | one column per color (each cell = a color
**suffix code**) | applicable model range | **`No. blok`** (which assembly, e.g. `F-13`) | **`No.
Ref`** (balloon in that block).

Example (PCX160): `COVER SET, L. BODY`, base `83650-K1Z-NA0` -> suffix `ZE` (Mat Gunpowder Black
`NH-436M`), `ZD` (Mat Solar Red `R-378M`), `ZC` (Pearl White `NH-341P`), `ZB` (Mat Bullet Silver
`NH-389M`). **Real part number = base + suffix.** Color data joins to diagrams by `(block code, ref
no)`.

## Serial-range & variant applicability (2024)

A position can resolve to different part numbers depending on:

- **Frame serial-number range** — e.g. `61101-MCE-000` up to No. `1008000`; `61101-MCE-010` from
  `1008001` onward. (`No. Seri` column.)
- **Model variant** — e.g. `STD` vs `ABS`, with **per-variant quantities** (separate `Jumlah`
  columns).

## Standard / bulk parts reference

Generic parts (e.g. "Pipa vinyl") listed by **standard number** vs **bulk/roll ("borongan")
number**, with dimensions (inner/outer diameter, length). Modeled as normal parts with `specs`
plus a `bulk` kind on the part number.

## Naming & numbering conventions

- **Descriptions are English, comma-inverted:** `GASKET, CYLINDER HEAD` = "cylinder head gasket";
  `COVER SET, L. BODY`. Names are intentionally not translated (international standard). -> we need a
  `name_normalized` + `aliases` layer for natural/local-language search
  (e.g. Indonesian "paking kepala silinder").
- **Part number anatomy** (per front matter): `[function+model] - [kode] - [modifikasi]` plus color
  code / subcontractor code suffixes. Standard parts encode dimensions instead. Treat the value as an
  opaque searchable string; optionally parse.
- **Abbreviations:** `COMP.`=complete, `ASSY`=assembly, `L./R.`=left/right, `FR./RR.`=front/rear,
  `STD`, `EX./IN.`=exhaust/inlet, etc.

## 2008 -> 2024 evolution

Backbone (group -> assembly -> diagram + balloon numbers + parts table + FRT table) is **unchanged**.
2024 adds: explicit **color-variant matrix**, **serial-range + variant applicability with
per-variant qty**, an expanded **standard/bulk parts** section, and cleaner typography. The schema
targets the 2024 superset; 2008 data maps in as the trivial case (one color, one variant, no ranges).

## AI ingestion targets (per page)

- Parts table -> `assembly_items` + `parts` + `part_numbers` (+ `item_resolutions` for serial/variant).
- Exploded diagram -> detect balloons -> `dots (x,y)`; auto-crop the diagram region; capture cross-refs.
- FRT table -> `service_items`.
- Color index -> `colors` + `part_color_variants`.
- Normalize names, propose `aliases` and **interchange merges** for admin approval (never auto-merge).

## Reference examples

- BeAT (2008): `E-3 Cylinder Head` detail page; `KELOMPOK RANGKA` (frame) index grid. Edition
  `TST 08 PC 002`, dated 2008-05-06.
- PCX160 (2024): color index `PCX160 (WW160As) TIPE ABS`; `KELOMPOK MESIN` index grid; "Pipa vinyl"
  standard-parts tables. Dated 2024-10-20. Type code `WW160As`, variants `STD`/`ABS`.
