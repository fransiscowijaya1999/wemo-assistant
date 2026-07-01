import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../models.dart';

/// Offline lookup over the local replica — the core clerk workflow. Any
/// number (oem/alternate/superseded/aftermarket), part name, or alias resolves
/// to the canonical part; part detail gathers its numbers, color variants,
/// aliases, and the diagram positions it appears in.
class LookupRepository {
  LookupRepository(this.db);

  final AppDatabase db;

  /// Search parts by part number, name, or alias (substring, case-insensitive).
  Future<List<PartSearchResult>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];
    final pattern = '%$q%';

    final rows = await db.customSelect(
      'SELECT p.id AS part_id, '
      '       COALESCE(p.name_normalized, p.name_raw) AS name, '
      '       (SELECT value FROM part_numbers WHERE part_id = p.id AND is_primary = 1 LIMIT 1) AS primary_number, '
      '       (SELECT value FROM part_numbers WHERE part_id = p.id AND value LIKE ? LIMIT 1) AS matched_number '
      'FROM parts p '
      'WHERE p.id IN ( '
      '  SELECT part_id FROM part_numbers WHERE value LIKE ? '
      '  UNION SELECT id FROM parts WHERE name_normalized LIKE ? OR name_raw LIKE ? '
      '  UNION SELECT part_id FROM aliases WHERE term LIKE ? '
      ') '
      'ORDER BY (matched_number IS NULL), name '
      'LIMIT 50',
      variables: [for (var i = 0; i < 5; i++) Variable<String>(pattern)],
      readsFrom: {db.parts, db.partNumbers, db.aliases},
    ).get();

    return rows
        .map(
          (r) => PartSearchResult(
            partId: r.read<String>('part_id'),
            name: r.read<String>('name'),
            primaryNumber: r.read<String?>('primary_number'),
            matchedNumber: r.read<String?>('matched_number'),
          ),
        )
        .toList();
  }

  Future<PartDetail?> partDetail(String partId) async {
    final part = await (db.select(db.parts)..where((t) => t.id.equals(partId))).getSingleOrNull();
    if (part == null) return null;

    final numbers =
        await (db.select(db.partNumbers)
              ..where((t) => t.partId.equals(partId))
              ..orderBy([
                (t) => OrderingTerm(expression: t.isPrimary, mode: OrderingMode.desc),
                (t) => OrderingTerm(expression: t.value),
              ]))
            .get();

    final colorRows = await db.customSelect(
      'SELECT pcv.full_number, pcv.suffix_code, c.code AS color_code, c.name AS color_name '
      'FROM part_color_variants pcv JOIN colors c ON c.id = pcv.color_id '
      'WHERE pcv.part_id = ? ORDER BY c.code',
      variables: [Variable<String>(partId)],
      readsFrom: {db.partColorVariants, db.colors},
    ).get();

    final aliasRows =
        await (db.select(db.aliases)..where((t) => t.partId.equals(partId))).get();

    final placementRows = await db.customSelect(
      'SELECT ai.id AS item_id, ai.ref_no, a.id AS assembly_id, a.code, a.name, m.brand, m.model '
      'FROM assembly_items ai '
      'JOIN assemblies a ON a.id = ai.assembly_id '
      'JOIN machines m ON m.id = a.machine_id '
      'WHERE ai.base_part_id = ? ORDER BY m.model, a.code',
      variables: [Variable<String>(partId)],
      readsFrom: {db.assemblyItems, db.assemblies, db.machines},
    ).get();

    return PartDetail(
      id: part.id,
      name: part.nameNormalized ?? part.nameRaw,
      category: part.category,
      notes: part.notes,
      numbers: numbers
          .map((n) => PartNumberView(value: n.value, kind: n.kind, brand: n.brand, isPrimary: n.isPrimary))
          .toList(),
      colorVariants: colorRows
          .map(
            (r) => ColorVariantView(
              fullNumber: r.read<String?>('full_number'),
              suffixCode: r.read<String?>('suffix_code'),
              colorCode: r.read<String>('color_code'),
              colorName: r.read<String>('color_name'),
            ),
          )
          .toList(),
      aliases: aliasRows.map((a) => a.term).toList(),
      placements: placementRows
          .map(
            (r) => PartPlacement(
              itemId: r.read<String>('item_id'),
              refNo: r.read<String>('ref_no'),
              assemblyId: r.read<String>('assembly_id'),
              assemblyCode: r.read<String>('code'),
              assemblyName: r.read<String>('name'),
              machineLabel: '${r.read<String>('brand')} ${r.read<String>('model')}',
            ),
          )
          .toList(),
    );
  }
}
