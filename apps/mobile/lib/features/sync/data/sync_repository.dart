import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

/// Applies sync pages to the local replica and owns the sync cursor.
///
/// Per row: `deletedAt != null` -> delete the local row (soft-delete
/// propagation); otherwise upsert. Each page is applied in one transaction and
/// is idempotent, so a retried page is harmless.
class SyncRepository {
  SyncRepository(this.db);

  final AppDatabase db;

  // --- Cursor / bookkeeping -------------------------------------------------

  Future<String> currentCursor() async {
    final row = await (db.select(db.syncStates)..where((t) => t.id.equals(1))).getSingleOrNull();
    return row?.cursor ?? '0';
  }

  Future<DateTime?> lastSyncedAt() async {
    final row = await (db.select(db.syncStates)..where((t) => t.id.equals(1))).getSingleOrNull();
    return row?.lastSyncedAt;
  }

  Future<void> saveCursor(String cursor) async {
    await db
        .into(db.syncStates)
        .insertOnConflictUpdate(SyncStatesCompanion.insert(id: const Value(1), cursor: Value(cursor)));
  }

  Future<void> markSynced(DateTime when) async {
    await db.into(db.syncStates).insertOnConflictUpdate(
      SyncStatesCompanion.insert(id: const Value(1), lastSyncedAt: Value(when)),
    );
  }

  /// Reset to a full sync (recovery / "force full sync").
  Future<void> resetCursor() => saveCursor('0');

  /// Wipe the mirrored catalog so a full sync rebuilds it from scratch,
  /// discarding any orphan rows the delta feed can no longer tombstone.
  Future<void> clearCatalog() => db.clearCatalog();

  // --- Apply a page ---------------------------------------------------------

  Future<void> applyPage(Map<String, List<Map<String, dynamic>>> tables) async {
    await db.transaction(() async {
      for (final entry in tables.entries) {
        await _applyTable(entry.key, entry.value);
      }
    });
  }

  Future<void> _applyTable(String name, List<Map<String, dynamic>> rows) async {
    switch (name) {
      case 'machines':
        return _apply(db.machines, rows, _machine);
      case 'machineVariants':
        return _apply(db.machineVariants, rows, _machineVariant);
      case 'colors':
        return _apply(db.colors, rows, _color);
      case 'assemblies':
        return _apply(db.assemblies, rows, _assembly);
      case 'assemblyItems':
        return _apply(db.assemblyItems, rows, _assemblyItem);
      case 'itemResolutions':
        return _apply(db.itemResolutions, rows, _itemResolution);
      case 'dots':
        return _apply(db.dots, rows, _dot);
      case 'assemblyLinks':
        return _apply(db.assemblyLinks, rows, _assemblyLink);
      case 'parts':
        return _apply(db.parts, rows, _part);
      case 'partNumbers':
        return _apply(db.partNumbers, rows, _partNumber);
      case 'partColorVariants':
        return _apply(db.partColorVariants, rows, _partColorVariant);
      case 'aliases':
        return _apply(db.aliases, rows, _alias);
      case 'serviceItems':
        return _apply(db.serviceItems, rows, _serviceItem);
      default:
        return; // unknown table (forward-compat): ignore
    }
  }

  /// Split a table's rows into deletes + upserts and apply both.
  Future<void> _apply<T extends Table, D>(
    TableInfo<T, D> table,
    List<Map<String, dynamic>> rows,
    Insertable<D> Function(Map<String, dynamic>) toRow,
  ) async {
    final upserts = <Insertable<D>>[];
    final deleteIds = <String>[];
    for (final r in rows) {
      if (r['deletedAt'] != null) {
        deleteIds.add(r['id'] as String);
      } else {
        upserts.add(toRow(r));
      }
    }

    if (deleteIds.isNotEmpty) {
      final placeholders = List.filled(deleteIds.length, '?').join(', ');
      await db.customStatement(
        'DELETE FROM ${table.actualTableName} WHERE id IN ($placeholders)',
        deleteIds,
      );
    }
    if (upserts.isNotEmpty) {
      await db.batch((b) => b.insertAllOnConflictUpdate(table, upserts));
    }
  }
}

// --- JSON -> companion mappers ---------------------------------------------

DateTime _dt(dynamic v) => DateTime.parse(v as String);
DateTime? _dtN(dynamic v) => v == null ? null : DateTime.parse(v as String);
double _d(dynamic v) => (v as num).toDouble();
double? _dN(dynamic v) => v == null ? null : (v as num).toDouble();
String? _json(dynamic v) => v == null ? null : jsonEncode(v);

MachinesCompanion _machine(Map<String, dynamic> r) => MachinesCompanion.insert(
  id: r['id'] as String,
  brand: r['brand'] as String,
  model: r['model'] as String,
  typeCode: Value(r['typeCode'] as String?),
  kCode: Value(r['kCode'] as String?),
  market: Value(r['market'] as String?),
  engineSeries: Value(r['engineSeries'] as String?),
  frameSeries: Value(r['frameSeries'] as String?),
  yearFrom: Value(r['yearFrom'] as int?),
  yearTo: Value(r['yearTo'] as int?),
  catalogEdition: Value(r['catalogEdition'] as String?),
  catalogDate: Value(r['catalogDate'] as String?),
  notes: Value(r['notes'] as String?),
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);

MachineVariantsCompanion _machineVariant(Map<String, dynamic> r) => MachineVariantsCompanion.insert(
  id: r['id'] as String,
  machineId: r['machineId'] as String,
  name: r['name'] as String,
  note: Value(r['note'] as String?),
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);

ColorsCompanion _color(Map<String, dynamic> r) => ColorsCompanion.insert(
  id: r['id'] as String,
  machineId: r['machineId'] as String,
  code: r['code'] as String,
  name: r['name'] as String,
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);

AssembliesCompanion _assembly(Map<String, dynamic> r) => AssembliesCompanion.insert(
  id: r['id'] as String,
  machineId: r['machineId'] as String,
  groupType: r['groupType'] as String,
  code: r['code'] as String,
  name: r['name'] as String,
  imageRef: Value(r['imageRef'] as String?),
  imageCode: Value(r['imageCode'] as String?),
  width: Value(r['width'] as int?),
  height: Value(r['height'] as int?),
  pageNo: Value(r['pageNo'] as int?),
  sortOrder: Value(r['sortOrder'] as int?),
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);

AssemblyItemsCompanion _assemblyItem(Map<String, dynamic> r) => AssemblyItemsCompanion.insert(
  id: r['id'] as String,
  assemblyId: r['assemblyId'] as String,
  refNo: r['refNo'] as String,
  basePartId: Value(r['basePartId'] as String?),
  note: Value(r['note'] as String?),
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);

ItemResolutionsCompanion _itemResolution(Map<String, dynamic> r) => ItemResolutionsCompanion.insert(
  id: r['id'] as String,
  assemblyItemId: r['assemblyItemId'] as String,
  partNumberId: r['partNumberId'] as String,
  qty: Value(r['qty'] as int? ?? 1),
  variantId: Value(r['variantId'] as String?),
  serialFrom: Value(r['serialFrom'] as String?),
  serialTo: Value(r['serialTo'] as String?),
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);

DotsCompanion _dot(Map<String, dynamic> r) => DotsCompanion.insert(
  id: r['id'] as String,
  assemblyItemId: r['assemblyItemId'] as String,
  x: _d(r['x']),
  y: _d(r['y']),
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);

AssemblyLinksCompanion _assemblyLink(Map<String, dynamic> r) => AssemblyLinksCompanion.insert(
  id: r['id'] as String,
  fromAssemblyId: r['fromAssemblyId'] as String,
  toCode: r['toCode'] as String,
  toAssemblyId: Value(r['toAssemblyId'] as String?),
  x: Value(_dN(r['x'])),
  y: Value(_dN(r['y'])),
  label: Value(r['label'] as String?),
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);

PartsCompanion _part(Map<String, dynamic> r) => PartsCompanion.insert(
  id: r['id'] as String,
  nameRaw: r['nameRaw'] as String,
  nameNormalized: Value(r['nameNormalized'] as String?),
  category: Value(r['category'] as String?),
  specs: Value(_json(r['specs'])),
  notes: Value(r['notes'] as String?),
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);

PartNumbersCompanion _partNumber(Map<String, dynamic> r) => PartNumbersCompanion.insert(
  id: r['id'] as String,
  partId: r['partId'] as String,
  value: r['value'] as String,
  kind: Value(r['kind'] as String? ?? 'oem'),
  brand: Value(r['brand'] as String?),
  note: Value(r['note'] as String?),
  isPrimary: Value(r['isPrimary'] as bool? ?? false),
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);

PartColorVariantsCompanion _partColorVariant(Map<String, dynamic> r) => PartColorVariantsCompanion.insert(
  id: r['id'] as String,
  partId: r['partId'] as String,
  colorId: r['colorId'] as String,
  suffixCode: Value(r['suffixCode'] as String?),
  fullNumber: Value(r['fullNumber'] as String?),
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);

AliasesCompanion _alias(Map<String, dynamic> r) => AliasesCompanion.insert(
  id: r['id'] as String,
  partId: r['partId'] as String,
  term: r['term'] as String,
  lang: Value(r['lang'] as String?),
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);

ServiceItemsCompanion _serviceItem(Map<String, dynamic> r) => ServiceItemsCompanion.insert(
  id: r['id'] as String,
  assemblyId: r['assemblyId'] as String,
  name: r['name'] as String,
  refNo: Value(r['refNo'] as String?),
  frtHours: Value(_dN(r['frtHours'])),
  note: Value(r['note'] as String?),
  updatedAt: _dt(r['updatedAt']),
  deletedAt: Value(_dtN(r['deletedAt'])),
);
