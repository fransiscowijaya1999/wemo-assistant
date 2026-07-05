import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/util/serial.dart';
import '../models.dart';

/// Offline lookup over the local replica — the core clerk workflow. Any
/// number (oem/alternate/superseded/aftermarket), part name, or alias resolves
/// to the canonical part; part detail gathers its numbers, color variants,
/// aliases, and the diagram positions it appears in.
class LookupRepository {
  LookupRepository(this.db);

  final AppDatabase db;

  /// Search parts by part number, name, or alias — mirrors the backend
  /// `searchParts` engine: token search (parts ranked by how many query words
  /// match ANY field, so extra words like the motorcycle model don't break the
  /// match) and dash-insensitive/partial part numbers ("9430125120" or
  /// "94301" both find 94301-25120).
  Future<List<PartSearchResult>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final tokens = q
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 2)
        .toSet()
        .take(8)
        .toList();
    final terms = tokens.isEmpty ? [q.toLowerCase()] : tokens;

    final score = <String, int>{};
    for (final term in terms) {
      for (final id in await _idsMatchingTerm(term)) {
        score[id] = (score[id] ?? 0) + 1;
      }
    }
    if (score.isEmpty) return [];

    final ids = (score.entries.toList()..sort((a, b) => b.value.compareTo(a.value)))
        .take(50)
        .map((e) => e.key)
        .toList();

    final byId = {for (final r in await partsByIds(ids, matchTerms: terms)) r.partId: r};
    return [for (final id in ids) if (byId[id] != null) byId[id]!];
  }

  /// Part ids matching one term (substring, case-insensitive) in any field.
  /// Part numbers also match with separators stripped.
  Future<Set<String>> _idsMatchingTerm(String term) async {
    final pattern = '%$term%';
    final condensed = term.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
    final rows = await db.customSelect(
      'SELECT part_id AS id FROM part_numbers '
      "WHERE value LIKE ?1 OR (?2 != '' AND replace(value, '-', '') LIKE ?3) "
      'UNION SELECT id FROM parts WHERE name_normalized LIKE ?1 OR name_raw LIKE ?1 '
      'UNION SELECT part_id AS id FROM aliases WHERE term LIKE ?1',
      variables: [
        Variable<String>(pattern),
        Variable<String>(condensed),
        Variable<String>('%$condensed%'),
      ],
      readsFrom: {db.parts, db.partNumbers, db.aliases},
    ).get();
    return {for (final r in rows) r.read<String>('id')};
  }

  /// Display rows for known part ids, in the given order — shared by search
  /// results and the recent-parts list. When [matchTerms] is set, also reports
  /// which number/alias matched (why this hit came up).
  Future<List<PartSearchResult>> partsByIds(
    List<String> ids, {
    List<String>? matchTerms,
  }) async {
    if (ids.isEmpty) return [];
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.customSelect(
      'SELECT p.id AS part_id, '
      '       COALESCE(p.name_normalized, p.name_raw) AS name, '
      '       (SELECT value FROM part_numbers WHERE part_id = p.id AND is_primary = 1 LIMIT 1) AS primary_number, '
      '       (SELECT value FROM part_numbers WHERE part_id = p.id LIMIT 1) AS any_number, '
      "       (SELECT group_concat(DISTINCT m.brand || ' ' || m.model) FROM assembly_items ai "
      '        JOIN assemblies a ON a.id = ai.assembly_id '
      '        JOIN machines m ON m.id = a.machine_id '
      '        WHERE ai.base_part_id = p.id) AS machines '
      'FROM parts p WHERE p.id IN ($placeholders)',
      variables: [for (final id in ids) Variable<String>(id)],
      readsFrom: {db.parts, db.partNumbers, db.assemblyItems, db.assemblies, db.machines},
    ).get();

    final matchedNumber = <String, String>{};
    final matchedAlias = <String, String>{};
    if (matchTerms != null && matchTerms.isNotEmpty) {
      final numberOr = <String>[];
      final aliasOr = <String>[];
      final numberVars = <Variable<String>>[];
      final aliasVars = <Variable<String>>[];
      for (final term in matchTerms) {
        final condensed = term.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '');
        numberOr.add("(value LIKE ? OR (? != '' AND replace(value, '-', '') LIKE ?))");
        numberVars
          ..add(Variable<String>('%$term%'))
          ..add(Variable<String>(condensed))
          ..add(Variable<String>('%$condensed%'));
        aliasOr.add('term LIKE ?');
        aliasVars.add(Variable<String>('%$term%'));
      }
      final numberRows = await db.customSelect(
        'SELECT part_id, value FROM part_numbers '
        'WHERE part_id IN ($placeholders) AND (${numberOr.join(' OR ')})',
        variables: [for (final id in ids) Variable<String>(id), ...numberVars],
        readsFrom: {db.partNumbers},
      ).get();
      for (final r in numberRows) {
        matchedNumber.putIfAbsent(r.read<String>('part_id'), () => r.read<String>('value'));
      }
      final aliasRows = await db.customSelect(
        'SELECT part_id, term FROM aliases '
        'WHERE part_id IN ($placeholders) AND (${aliasOr.join(' OR ')})',
        variables: [for (final id in ids) Variable<String>(id), ...aliasVars],
        readsFrom: {db.aliases},
      ).get();
      for (final r in aliasRows) {
        matchedAlias.putIfAbsent(r.read<String>('part_id'), () => r.read<String>('term'));
      }
    }

    final byId = <String, PartSearchResult>{};
    for (final r in rows) {
      final id = r.read<String>('part_id');
      byId[id] = PartSearchResult(
        partId: id,
        name: r.read<String>('name'),
        primaryNumber: r.read<String?>('primary_number') ?? r.read<String?>('any_number'),
        matchedNumber: matchedNumber[id],
        matchedAlias: matchedAlias[id],
        machines: r.read<String?>('machines')?.replaceAll(',', ', '),
      );
    }
    return [for (final id in ids) if (byId[id] != null) byId[id]!];
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

    // Per placement, the variant/serial restrictions under which one of THIS
    // part's numbers is the resolution. An unrestricted resolution means the
    // part fits everything there, so no label.
    final applicabilityRows = await db.customSelect(
      'SELECT ir.assembly_item_id AS item_id, ir.variant_id, mv.name AS variant_name, '
      'ir.serial_from, ir.serial_to '
      'FROM item_resolutions ir '
      'JOIN part_numbers pn ON pn.id = ir.part_number_id '
      'LEFT JOIN machine_variants mv ON mv.id = ir.variant_id '
      'WHERE pn.part_id = ?',
      variables: [Variable<String>(partId)],
      readsFrom: {db.itemResolutions, db.partNumbers, db.machineVariants},
    ).get();
    final applicabilityByItem = <String, Set<String>?>{};
    for (final r in applicabilityRows) {
      final itemId = r.read<String>('item_id');
      if (applicabilityByItem.containsKey(itemId) && applicabilityByItem[itemId] == null) {
        continue; // already known unrestricted
      }
      final label = applicabilityLabel(
        variantName: r.read<String?>('variant_name'),
        serialFrom: r.read<String?>('serial_from'),
        serialTo: r.read<String?>('serial_to'),
      );
      if (label == null) {
        applicabilityByItem[itemId] = null; // unrestricted wins
      } else {
        (applicabilityByItem[itemId] ??= <String>{}).add(label);
      }
    }

    // Substitutes: union both columns of the undirected link to the other side,
    // resolving its name, a primary number, and whether it's the current
    // replacement (soft-deleted links are already absent from the replica).
    final substituteRows = await db.customSelect(
      'SELECT p.id AS other_id, '
      'COALESCE(p.name_normalized, p.name_raw) AS name, '
      'p.is_current_replacement AS is_current, ps.note AS note, '
      '(SELECT pn.value FROM part_numbers pn WHERE pn.part_id = p.id '
      ' ORDER BY pn.is_primary DESC, pn.value LIMIT 1) AS primary_number '
      'FROM part_substitutes ps '
      'JOIN parts p ON p.id = CASE WHEN ps.part_id = ? THEN ps.substitute_part_id ELSE ps.part_id END '
      'WHERE ps.part_id = ? OR ps.substitute_part_id = ? '
      'ORDER BY is_current DESC, name',
      variables: [Variable<String>(partId), Variable<String>(partId), Variable<String>(partId)],
      readsFrom: {db.partSubstitutes, db.parts, db.partNumbers},
    ).get();

    return PartDetail(
      id: part.id,
      name: part.nameNormalized ?? part.nameRaw,
      category: part.category,
      notes: part.notes,
      isCurrentReplacement: part.isCurrentReplacement,
      substitutes: substituteRows
          .map(
            (r) => SubstituteView(
              partId: r.read<String>('other_id'),
              name: r.read<String>('name'),
              primaryNumber: r.read<String?>('primary_number'),
              note: r.read<String?>('note'),
              isCurrent: r.read<bool>('is_current'),
            ),
          )
          .toList(),
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
      placements: placementRows.map((r) {
        final itemId = r.read<String>('item_id');
        final labels = applicabilityByItem[itemId];
        return PartPlacement(
          itemId: itemId,
          refNo: r.read<String>('ref_no'),
          assemblyId: r.read<String>('assembly_id'),
          assemblyCode: r.read<String>('code'),
          assemblyName: r.read<String>('name'),
          machineLabel: '${r.read<String>('brand')} ${r.read<String>('model')}',
          applicability: (labels == null || labels.isEmpty) ? null : labels.join(', '),
        );
      }).toList(),
    );
  }
}
