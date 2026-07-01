import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Machines,
    MachineVariants,
    Colors,
    Assemblies,
    AssemblyItems,
    ItemResolutions,
    Dots,
    AssemblyLinks,
    Parts,
    PartNumbers,
    PartColorVariants,
    Aliases,
    ServiceItems,
    SyncStates,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'wemo_clerk'));

  /// For tests: pass an in-memory or custom executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  /// The 13 mirrored catalog tables, keyed by the name the sync API uses
  /// (see apps/backend/src/routes/sync.ts `SYNC_TABLES`). Order matches the
  /// server so a full sync inserts parents before children where it matters.
  Map<String, TableInfo> get syncTables => {
    'machines': machines,
    'machineVariants': machineVariants,
    'colors': colors,
    'assemblies': assemblies,
    'assemblyItems': assemblyItems,
    'itemResolutions': itemResolutions,
    'dots': dots,
    'assemblyLinks': assemblyLinks,
    'parts': parts,
    'partNumbers': partNumbers,
    'partColorVariants': partColorVariants,
    'aliases': aliases,
    'serviceItems': serviceItems,
  };

  /// Live row count per mirrored table (soft-deleted rows are already removed).
  Future<Map<String, int>> tableCounts() async {
    final counts = <String, int>{};
    for (final entry in syncTables.entries) {
      final row = await customSelect(
        'SELECT COUNT(*) AS c FROM ${entry.value.actualTableName}',
      ).getSingle();
      counts[entry.key] = row.read<int>('c');
    }
    return counts;
  }
}
