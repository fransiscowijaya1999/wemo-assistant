// View models for the Search / Part-detail feature.

/// One search hit: a canonical part, plus why it matched.
class PartSearchResult {
  const PartSearchResult({
    required this.partId,
    required this.name,
    required this.primaryNumber,
    this.matchedNumber,
    this.matchedAlias,
    this.machines,
  });

  final String partId;
  final String name;
  final String? primaryNumber;

  /// A number on this part that matched the query (may equal [primaryNumber],
  /// or be an alternate/superseded number the clerk typed).
  final String? matchedNumber;

  /// An alias (local/colloquial term) that matched the query.
  final String? matchedAlias;

  /// "Honda BeAT 2008, Honda PCX160" — machines whose diagrams the part
  /// appears on; null when the part has no placements.
  final String? machines;
}

class PartNumberView {
  const PartNumberView({
    required this.value,
    required this.kind,
    required this.brand,
    required this.isPrimary,
  });

  final String value;
  final String kind; // oem | alternative | superseded | aftermarket | bulk
  final String? brand;
  final bool isPrimary;
}

class ColorVariantView {
  const ColorVariantView({
    required this.fullNumber,
    required this.suffixCode,
    required this.colorCode,
    required this.colorName,
  });

  final String? fullNumber; // base + suffix
  final String? suffixCode;
  final String colorCode; // NH-436M
  final String colorName; // Mat Gunpowder Black Metallic
}

/// Where a part sits in a diagram (a position on an assembly).
class PartPlacement {
  const PartPlacement({
    required this.itemId,
    required this.refNo,
    required this.assemblyId,
    required this.assemblyCode,
    required this.assemblyName,
    required this.machineLabel,
    this.applicability,
  });

  final String itemId;
  final String refNo;
  final String assemblyId;
  final String assemblyCode;
  final String assemblyName;
  final String machineLabel;

  /// "CBS, ABS" / "s/n 1000001–…" when this part only fits some variants or
  /// serials at this position; null when unrestricted.
  final String? applicability;
}

/// A part this one interchanges with (manual substitute link). Within a cluster
/// one part is the current replacement ([isCurrent]); the others are obsolete.
class SubstituteView {
  const SubstituteView({
    required this.partId,
    required this.name,
    required this.primaryNumber,
    required this.note,
    required this.isCurrent,
  });

  final String partId;
  final String name;
  final String? primaryNumber;
  final String? note;
  final bool isCurrent;
}

class PartDetail {
  const PartDetail({
    required this.id,
    required this.name,
    required this.category,
    required this.notes,
    required this.numbers,
    required this.colorVariants,
    required this.aliases,
    required this.placements,
    required this.substitutes,
    required this.isCurrentReplacement,
  });

  final String id;
  final String name;
  final String? category;
  final String? notes;
  final List<PartNumberView> numbers;
  final List<ColorVariantView> colorVariants;
  final List<String> aliases;
  final List<PartPlacement> placements;

  /// Parts this one can be replaced with; the current-replacement one is flagged.
  final List<SubstituteView> substitutes;

  /// True when this part itself is the current replacement in its cluster.
  final bool isCurrentReplacement;
}
