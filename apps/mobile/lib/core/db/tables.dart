import 'package:drift/drift.dart';

// Local drift replica of the backend catalog. These tables mirror
// apps/backend/src/db/schema.ts 1:1 (D1 and drift are both SQLite), minus the
// `users` table which is never synced. Rows arrive from GET /sync.
//
// Timestamps: the API sends `updatedAt`/`deletedAt` as ISO strings; we store
// them as `DateTime`. We keep only `updatedAt` + `deletedAt` (the replica never
// needs `createdAt`). Text UUID primary keys stay TEXT.
//
// A row with `deletedAt != null` is a soft delete — the sync repository removes
// the local row rather than storing it, so every row present here is live.

/// Columns every mirrored table carries for sync bookkeeping.
mixin _Synced on Table {
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class Machines extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get brand => text()();
  TextColumn get model => text()();
  TextColumn get typeCode => text().nullable()();
  TextColumn get kCode => text().nullable()();
  TextColumn get market => text().nullable()();
  TextColumn get engineSeries => text().nullable()();
  TextColumn get frameSeries => text().nullable()();
  IntColumn get yearFrom => integer().nullable()();
  IntColumn get yearTo => integer().nullable()();
  TextColumn get catalogEdition => text().nullable()();
  TextColumn get catalogDate => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MachineVariants extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get machineId => text()();
  TextColumn get name => text()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Colors extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get machineId => text()();
  TextColumn get code => text()();
  TextColumn get name => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'assemblies_machine', columns: {#machineId})
class Assemblies extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get machineId => text()();
  TextColumn get groupType => text()(); // engine | frame
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get imageRef => text().nullable()(); // R2 key; image fetched in M2
  TextColumn get imageCode => text().nullable()();
  IntColumn get width => integer().nullable()();
  IntColumn get height => integer().nullable()();
  IntColumn get pageNo => integer().nullable()();
  IntColumn get sortOrder => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'assembly_items_assembly', columns: {#assemblyId})
class AssemblyItems extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get assemblyId => text()();
  TextColumn get refNo => text()();
  TextColumn get basePartId => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'item_resolutions_item', columns: {#assemblyItemId})
class ItemResolutions extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get assemblyItemId => text()();
  TextColumn get partNumberId => text()();
  IntColumn get qty => integer().withDefault(const Constant(1))();
  TextColumn get variantId => text().nullable()();
  TextColumn get serialFrom => text().nullable()();
  TextColumn get serialTo => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'dots_item', columns: {#assemblyItemId})
class Dots extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get assemblyItemId => text()();
  RealColumn get x => real()(); // normalized 0..1 on the diagram image
  RealColumn get y => real()();

  @override
  Set<Column> get primaryKey => {id};
}

class AssemblyLinks extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get fromAssemblyId => text()();
  TextColumn get toCode => text()();
  TextColumn get toAssemblyId => text().nullable()();
  RealColumn get x => real().nullable()();
  RealColumn get y => real().nullable()();
  TextColumn get label => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'parts_name_normalized', columns: {#nameNormalized})
class Parts extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get nameRaw => text()();
  TextColumn get nameNormalized => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get specs => text().nullable()(); // JSON string
  TextColumn get notes => text().nullable()();
  // True when this part is the current replacement in its substitute cluster.
  BoolColumn get isCurrentReplacement => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Manual, symmetric substitute link between two DIFFERENT canonical parts
/// (mirrors backend `part_substitutes`; one undirected row per pair). The
/// current-replacement designation lives on `Parts.isCurrentReplacement`, not here.
@TableIndex(name: 'part_substitutes_part', columns: {#partId})
@TableIndex(name: 'part_substitutes_sub', columns: {#substitutePartId})
class PartSubstitutes extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get partId => text()();
  TextColumn get substitutePartId => text()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'part_numbers_value', columns: {#value})
@TableIndex(name: 'part_numbers_part', columns: {#partId})
class PartNumbers extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get partId => text()();
  TextColumn get value => text()(); // 12200-KVY-900
  TextColumn get kind => text().withDefault(const Constant('oem'))();
  TextColumn get brand => text().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'part_color_variants_part', columns: {#partId})
class PartColorVariants extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get partId => text()();
  TextColumn get colorId => text()();
  TextColumn get suffixCode => text().nullable()();
  TextColumn get fullNumber => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'aliases_term', columns: {#term})
class Aliases extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get partId => text()();
  TextColumn get term => text()();
  TextColumn get lang => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ServiceItems extends Table with _Synced {
  TextColumn get id => text()();
  TextColumn get assemblyId => text()();
  TextColumn get refNo => text().nullable()();
  TextColumn get name => text()();
  RealColumn get frtHours => real().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Local-only sync bookkeeping (single row, id = 1). Not mirrored from backend.
/// `cursor` is the opaque continuation token from GET /sync ("0" = full sync).
class SyncStates extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get cursor => text().withDefault(const Constant('0'))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
