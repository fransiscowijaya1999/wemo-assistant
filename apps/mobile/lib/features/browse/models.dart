// View models for the Browse feature (flattened joins the UI renders directly).

/// One row in the machine list (Browse root).
class MachineListItem {
  const MachineListItem({
    required this.id,
    required this.brand,
    required this.model,
    required this.yearFrom,
    required this.yearTo,
    required this.engineCount,
    required this.frameCount,
  });

  final String id;
  final String brand;
  final String model;
  final int? yearFrom;
  final int? yearTo;
  final int engineCount; // engine-group assemblies
  final int frameCount; // frame-group assemblies

  String get label => '$brand $model';

  String? get yearLabel {
    if (yearFrom == null && yearTo == null) return null;
    if (yearFrom != null && yearTo != null) {
      return yearFrom == yearTo ? '$yearFrom' : '$yearFrom–$yearTo';
    }
    return '${yearFrom ?? yearTo}';
  }
}

/// One tile in a machine's assembly grid.
class AssemblyTile {
  const AssemblyTile({
    required this.id,
    required this.code,
    required this.name,
    required this.groupType,
    required this.hasImage,
  });

  final String id;
  final String code; // E-1 / F-13
  final String name; // Cylinder Head
  final String groupType; // engine | frame
  final bool hasImage;
}

/// Assembly header + diagram geometry.
class AssemblyMeta {
  const AssemblyMeta({
    required this.id,
    required this.code,
    required this.name,
    required this.width,
    required this.height,
    required this.hasImage,
  });

  final String id;
  final String code;
  final String name;
  final int? width; // stored diagram pixel size, for aspect ratio
  final int? height;
  final bool hasImage;

  double? get aspectRatio =>
      (width != null && height != null && height! > 0) ? width! / height! : null;
}

/// A balloon dot on a diagram, resolved to its position + part.
class DiagramDot {
  const DiagramDot({
    required this.itemId,
    required this.refNo,
    required this.x,
    required this.y,
    required this.partName,
    required this.primaryNumber,
  });

  final String itemId;
  final String refNo; // balloon label
  final double x; // normalized 0..1 on the stored image
  final double y;
  final String? partName;
  final String? primaryNumber;
}
