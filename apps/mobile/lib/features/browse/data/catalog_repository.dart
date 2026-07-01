import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../models.dart';

/// Read-only queries over the local replica for the Browse feature.
class CatalogRepository {
  CatalogRepository(this.db);

  final AppDatabase db;

  /// All assemblies with their machine label, reactive to sync writes.
  Stream<List<AssemblyListItem>> watchAssemblies() {
    return db
        .customSelect(
          'SELECT a.id, a.code, a.name, a.group_type AS group_type, a.image_ref AS image_ref, '
          'm.brand, m.model '
          'FROM assemblies a JOIN machines m ON m.id = a.machine_id '
          'ORDER BY m.model, a.group_type, a.code',
          readsFrom: {db.assemblies, db.machines},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (r) => AssemblyListItem(
                  id: r.read<String>('id'),
                  code: r.read<String>('code'),
                  name: r.read<String>('name'),
                  groupType: r.read<String>('group_type'),
                  machineLabel: '${r.read<String>('brand')} ${r.read<String>('model')}',
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
