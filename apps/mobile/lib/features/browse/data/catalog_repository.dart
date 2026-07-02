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
    final m = await (db.select(db.machines)..where((t) => t.id.equals(a.machineId)))
        .getSingleOrNull();
    return AssemblyMeta(
      id: a.id,
      machineId: a.machineId,
      machineLabel: m == null ? '' : '${m.brand} ${m.model}',
      code: a.code,
      name: a.name,
      width: a.width,
      height: a.height,
      hasImage: a.imageRef != null,
    );
  }

  /// The machine's variants (CBS/ABS/…), for the fitment picker.
  Future<List<VariantOption>> machineVariants(String machineId) async {
    final rows = await (db.select(db.machineVariants)
          ..where((t) => t.machineId.equals(machineId))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
    return rows.map((v) => VariantOption(id: v.id, name: v.name)).toList();
  }

  /// Whether the fitment picker is worth showing for this machine: it has
  /// variants, or any of its resolutions is serial-ranged.
  Future<bool> fitmentAvailable(String machineId) async {
    final row = await db.customSelect(
      'SELECT EXISTS(SELECT 1 FROM machine_variants WHERE machine_id = ?1) '
      'OR EXISTS(SELECT 1 FROM item_resolutions ir '
      '   JOIN assembly_items ai ON ai.id = ir.assembly_item_id '
      '   JOIN assemblies a ON a.id = ai.assembly_id '
      '   WHERE a.machine_id = ?1 '
      '   AND (ir.serial_from IS NOT NULL OR ir.serial_to IS NOT NULL)) AS available',
      variables: [Variable<String>(machineId)],
      readsFrom: {db.machineVariants, db.itemResolutions, db.assemblyItems, db.assemblies},
    ).getSingle();
    return row.read<int>('available') == 1;
  }

  /// Balloon dots for an assembly, each resolved to its position's part name,
  /// primary number, and item_resolutions (actual number + qty + variant/serial
  /// applicability, unfiltered — the UI applies the fitment). One row per dot.
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

    final resolutionRows = await db.customSelect(
      'SELECT ir.assembly_item_id AS item_id, ir.qty, ir.variant_id, '
      'ir.serial_from, ir.serial_to, pn.value AS number_value, mv.name AS variant_name '
      'FROM item_resolutions ir '
      'JOIN assembly_items ai ON ai.id = ir.assembly_item_id '
      'LEFT JOIN part_numbers pn ON pn.id = ir.part_number_id '
      'LEFT JOIN machine_variants mv ON mv.id = ir.variant_id '
      'WHERE ai.assembly_id = ? ORDER BY (ir.variant_id IS NOT NULL), mv.name, pn.value',
      variables: [Variable<String>(assemblyId)],
      readsFrom: {db.itemResolutions, db.assemblyItems, db.partNumbers, db.machineVariants},
    ).get();

    final resolutionsByItem = <String, List<ItemResolutionView>>{};
    for (final r in resolutionRows) {
      resolutionsByItem.putIfAbsent(r.read<String>('item_id'), () => []).add(
            ItemResolutionView(
              partNumberValue: r.read<String?>('number_value'),
              qty: r.read<int>('qty'),
              variantId: r.read<String?>('variant_id'),
              variantName: r.read<String?>('variant_name'),
              serialFrom: r.read<String?>('serial_from'),
              serialTo: r.read<String?>('serial_to'),
            ),
          );
    }

    return rows
        .map(
          (r) => DiagramDot(
            itemId: r.read<String>('item_id'),
            refNo: r.read<String>('ref_no'),
            x: r.read<double>('x'),
            y: r.read<double>('y'),
            partName: r.read<String?>('part_name'),
            primaryNumber: r.read<String?>('primary_number'),
            resolutions: resolutionsByItem[r.read<String>('item_id')] ?? const [],
          ),
        )
        .toList();
  }
}
