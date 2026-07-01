import { sqliteTable, text, integer, real, index } from 'drizzle-orm/sqlite-core';

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

/** App-generated UUID primary key (safe for offline creation + sync). */
const pk = () => text('id').primaryKey().$defaultFn(() => crypto.randomUUID());

/** Sync/audit columns present on every syncable table (ms epoch, soft delete). */
const timestamps = () => ({
  createdAt: integer('created_at', { mode: 'timestamp_ms' }).notNull().$defaultFn(() => new Date()),
  updatedAt: integer('updated_at', { mode: 'timestamp_ms' }).notNull().$defaultFn(() => new Date()),
  deletedAt: integer('deleted_at', { mode: 'timestamp_ms' }),
});

// ---------------------------------------------------------------------------
// Machines
// ---------------------------------------------------------------------------

export const machines = sqliteTable('machines', {
  id: pk(),
  brand: text('brand').notNull(),
  model: text('model').notNull(),
  typeCode: text('type_code'), // e.g. ANC110CCI9 / WW160As
  kCode: text('k_code'), // e.g. K81
  market: text('market'),
  engineSeries: text('engine_series'),
  frameSeries: text('frame_series'),
  yearFrom: integer('year_from'),
  yearTo: integer('year_to'),
  catalogEdition: text('catalog_edition'),
  catalogDate: text('catalog_date'),
  notes: text('notes'),
  ...timestamps(),
});

export const machineVariants = sqliteTable('machine_variants', {
  id: pk(),
  machineId: text('machine_id').notNull().references(() => machines.id),
  name: text('name').notNull(), // STD | ABS | CBS ...
  note: text('note'),
  ...timestamps(),
}, (t) => [index('machine_variants_machine_idx').on(t.machineId)]);

export const colors = sqliteTable('colors', {
  id: pk(),
  machineId: text('machine_id').notNull().references(() => machines.id),
  code: text('code').notNull(), // NH-436M
  name: text('name').notNull(), // Mat Gunpowder Black Metallic
  ...timestamps(),
}, (t) => [index('colors_machine_idx').on(t.machineId)]);

// ---------------------------------------------------------------------------
// Assemblies (exploded-diagram pages) and positions
// ---------------------------------------------------------------------------

export const assemblies = sqliteTable('assemblies', {
  id: pk(),
  machineId: text('machine_id').notNull().references(() => machines.id),
  groupType: text('group_type', { enum: ['engine', 'frame'] }).notNull(),
  code: text('code').notNull(), // E-3 / F-13
  name: text('name').notNull(), // Cylinder Head
  imageRef: text('image_ref'), // R2 storage key
  imageCode: text('image_code'), // KVYIE0300
  width: integer('width'),
  height: integer('height'),
  pageNo: integer('page_no'),
  sortOrder: integer('sort_order'),
  ...timestamps(),
}, (t) => [index('assemblies_machine_code_idx').on(t.machineId, t.code)]);

/** A position on a diagram: "balloon `ref_no` on this assembly". */
export const assemblyItems = sqliteTable('assembly_items', {
  id: pk(),
  assemblyId: text('assembly_id').notNull().references(() => assemblies.id),
  refNo: text('ref_no').notNull(), // "12" (string: can be non-numeric)
  basePartId: text('base_part_id').references(() => parts.id),
  note: text('note'),
  ...timestamps(),
}, (t) => [index('assembly_items_assembly_idx').on(t.assemblyId)]);

/** Which part number a position resolves to, filtered by variant + serial range. */
export const itemResolutions = sqliteTable('item_resolutions', {
  id: pk(),
  assemblyItemId: text('assembly_item_id').notNull().references(() => assemblyItems.id),
  partNumberId: text('part_number_id').notNull().references(() => partNumbers.id),
  qty: integer('qty').notNull().default(1),
  variantId: text('variant_id').references(() => machineVariants.id),
  serialFrom: text('serial_from'),
  serialTo: text('serial_to'),
  ...timestamps(),
}, (t) => [index('item_resolutions_item_idx').on(t.assemblyItemId)]);

/** Balloon coordinates (normalized 0..1). A position can have several. */
export const dots = sqliteTable('dots', {
  id: pk(),
  assemblyItemId: text('assembly_item_id').notNull().references(() => assemblyItems.id),
  x: real('x').notNull(),
  y: real('y').notNull(),
  ...timestamps(),
}, (t) => [index('dots_item_idx').on(t.assemblyItemId)]);

/** Cross-reference drawn on a diagram pointing at a neighboring assembly. */
export const assemblyLinks = sqliteTable('assembly_links', {
  id: pk(),
  fromAssemblyId: text('from_assembly_id').notNull().references(() => assemblies.id),
  toCode: text('to_code').notNull(), // F-16
  toAssemblyId: text('to_assembly_id').references(() => assemblies.id),
  x: real('x'),
  y: real('y'),
  label: text('label'),
  ...timestamps(),
}, (t) => [index('assembly_links_from_idx').on(t.fromAssemblyId)]);

// ---------------------------------------------------------------------------
// Parts (canonical) + numbers + variants
// ---------------------------------------------------------------------------

export const parts = sqliteTable('parts', {
  id: pk(),
  nameRaw: text('name_raw').notNull(), // "GASKET, CYLINDER HEAD"
  nameNormalized: text('name_normalized'), // "Cylinder Head Gasket"
  category: text('category'),
  specs: text('specs', { mode: 'json' }).$type<Record<string, unknown>>(),
  notes: text('notes'),
  ...timestamps(),
}, (t) => [index('parts_name_normalized_idx').on(t.nameNormalized)]);

export const partNumbers = sqliteTable('part_numbers', {
  id: pk(),
  partId: text('part_id').notNull().references(() => parts.id),
  value: text('value').notNull(), // 12200-KVY-900
  kind: text('kind', {
    enum: ['oem', 'alternative', 'superseded', 'aftermarket', 'bulk'],
  }).notNull().default('oem'),
  brand: text('brand'), // NGK / Denso / Honda / Aspira
  note: text('note'),
  isPrimary: integer('is_primary', { mode: 'boolean' }).notNull().default(false),
  ...timestamps(),
}, (t) => [
  index('part_numbers_value_idx').on(t.value),
  index('part_numbers_part_idx').on(t.partId),
]);

/** Per-color specialization of a part number (base + color suffix). */
export const partColorVariants = sqliteTable('part_color_variants', {
  id: pk(),
  partId: text('part_id').notNull().references(() => parts.id),
  colorId: text('color_id').notNull().references(() => colors.id),
  suffixCode: text('suffix_code'), // ZE
  fullNumber: text('full_number'), // base + suffix
  ...timestamps(),
}, (t) => [index('part_color_variants_part_idx').on(t.partId)]);

/** Search synonyms and local/colloquial names. */
export const aliases = sqliteTable('aliases', {
  id: pk(),
  partId: text('part_id').notNull().references(() => parts.id),
  term: text('term').notNull(),
  lang: text('lang'), // id | en
  ...timestamps(),
}, (t) => [index('aliases_term_idx').on(t.term)]);

// ---------------------------------------------------------------------------
// Workshop labor (FRT) + users
// ---------------------------------------------------------------------------

export const serviceItems = sqliteTable('service_items', {
  id: pk(),
  assemblyId: text('assembly_id').notNull().references(() => assemblies.id),
  refNo: text('ref_no'),
  name: text('name').notNull(),
  frtHours: real('frt_hours'),
  note: text('note'),
  ...timestamps(),
}, (t) => [index('service_items_assembly_idx').on(t.assemblyId)]);

export const users = sqliteTable('users', {
  id: pk(),
  email: text('email').notNull().unique(),
  role: text('role', { enum: ['admin', 'clerk'] }).notNull().default('clerk'),
  displayName: text('display_name'),
  ...timestamps(),
});
