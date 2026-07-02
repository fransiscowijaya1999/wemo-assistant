import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../models.dart';

/// Read-only queries over the local replica for the Browse feature.
class CatalogRepository {
  CatalogRepository(this.db);

  final AppDatabase db;

  /// All machines with per-group assembly counts, reactive to sync writes.
  Stream<List<MachineListItem>> watchMachines() {
    return db
        .customSelect(
          'SELECT m.id, m.brand, m.model, m.year_from AS year_from, m.year_to AS year_to, '
          "SUM(CASE WHEN a.group_type = 'engine' THEN 1 ELSE 0 END) AS engine_count, "
          "SUM(CASE WHEN a.group_type = 'frame' THEN 1 ELSE 0 END) AS frame_count "
          'FROM machines m LEFT JOIN assemblies a ON a.machine_id = m.id '
          'GROUP BY m.id ORDER BY m.brand, m.model',
          readsFrom: {db.machines, db.assemblies},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => MachineListItem(
                  id: r.read<String>('id'),
                  brand: r.read<String>('brand'),
                  model: r.read<String>('model'),
                  yearFrom: r.read<int?>('year_from'),
                  yearTo: r.read<int?>('year_to'),
                  engineCount: r.read<int>('engine_count'),
                  frameCount: r.read<int>('frame_count'),
                ),
              )
              .toList(),
        );
  }

  /// One machine's assemblies in catalog order (both groups; the UI filters).
  /// Catalog order = sort_order when present, else the numeric part of the
  /// code ("E-2" before "E-10", which plain text ordering gets wrong).
  Stream<List<AssemblyTile>> watchMachineAssemblies(String machineId) {
    return db
        .customSelect(
          'SELECT id, code, name, group_type AS group_type, image_ref AS image_ref '
          'FROM assemblies WHERE machine_id = ? '
          'ORDER BY group_type, (sort_order IS NULL), sort_order, '
          "CAST(substr(code, instr(code, '-') + 1) AS INTEGER), code",
          variables: [Variable<String>(machineId)],
          readsFrom: {db.assemblies},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => AssemblyTile(
                  id: r.read<String>('id'),
                  code: r.read<String>('code'),
                  name: r.read<String>('name'),
                  groupType: r.read<String>('group_type'),
                  hasImage: r.read<String?>('image_ref') != null,
                ),
              )
              .toList(),
        );
  }

  Future<AssemblyMeta?> assemblyMeta(String id) async {
    final a = await (db.select(db.assemblies)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (a == null) return null;
    return AssemblyMeta(
      id: a.id,
      code: a.code,
      name: a.name,
      width: a.width,
      height: a.height,
      hasImage: a.imageRef != null,
    );
  }

  /// Balloon dots for an assembly, each resolved to its position's part name
  /// and primary number (for the tap sheet). One row per dot.
  Future<List<DiagramDot>> diagramDots(String assemblyId) async {
    final rows = await db.customSelect(
      'SELECT d.x, d.y, ai.ref_no AS ref_no, ai.id AS item_id, '
      'COALESCE(p.name_normalized, p.name_raw) AS part_name, '
      '(SELECT pn.value FROM part_numbers pn '
      ' WHERE pn.part_id = ai.base_part_id AND pn.is_primary = 1 LIMIT 1) AS primary_number '
      'FROM dots d '
      'JOIN assembly_items ai ON ai.id = d.assembly_item_id '
      'LEFT JOIN parts p ON p.id = ai.base_part_id '
      'WHERE ai.assembly_id = ?',
      variables: [Variable<String>(assemblyId)],
      readsFrom: {db.dots, db.assemblyItems, db.parts, db.partNumbers},
    ).get();

    return rows
        .map(
          (r) => DiagramDot(
            itemId: r.read<String>('item_id'),
            refNo: r.read<String>('ref_no'),
            x: r.read<double>('x'),
            y: r.read<double>('y'),
            partName: r.read<String?>('part_name'),
            primaryNumber: r.read<String?>('primary_number'),
          ),
        )
        .toList();
  }
}
