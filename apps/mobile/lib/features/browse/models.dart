// View models for the Browse feature (flattened joins the UI renders directly).

import '../../core/util/serial.dart';

/// The customer's bike as picked by the clerk: an optional machine variant
/// (CBS/ABS/…) and an optional frame serial. Filters which item resolutions
/// apply, mirroring the backend's ?variantId=&serial= semantics.
class Fitment {
  const Fitment({this.variantId, this.variantName, this.serial});

  final String? variantId;
  final String? variantName;
  final String? serial; // trimmed, non-empty when set

  bool get isActive => variantId != null || serial != null;

  String get label => [
        ?variantName,
        if (serial != null) 's/n $serial',
      ].join(' · ');
}

/// A machine variant the clerk can pick (from the synced machine_variants).
class VariantOption {
  const VariantOption({required this.id, required this.name});

  final String id;
  final String name;
}

/// One item_resolutions row: the actual part number a position resolves to,
/// with its variant/serial applicability.
class ItemResolutionView {
  const ItemResolutionView({
    required this.partNumberValue,
    required this.qty,
    required this.variantId,
    required this.variantName,
    required this.serialFrom,
    required this.serialTo,
  });

  final String? partNumberValue;
  final int qty;
  final String? variantId; // null = all variants
  final String? variantName;
  final String? serialFrom;
  final String? serialTo;

  /// Backend rule (assemblies.ts /:id/full): variant matches when the
  /// resolution is unrestricted or equals the filter; serial must fall in
  /// [serialFrom, serialTo] with null bounds open.
  bool appliesTo(Fitment fitment) {
    if (fitment.variantId != null && variantId != null && variantId != fitment.variantId) {
      return false;
    }
    if (fitment.serial != null && !serialInRange(fitment.serial!, serialFrom, serialTo)) {
      return false;
    }
    return true;
  }

  /// "CBS · s/n 1000001–…", or null when unrestricted.
  String? get label =>
      applicabilityLabel(variantName: variantName, serialFrom: serialFrom, serialTo: serialTo);
}

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
    required this.machineId,
    required this.machineLabel,
    required this.code,
    required this.name,
    required this.width,
    required this.height,
    required this.hasImage,
  });

  final String id;
  final String machineId;
  final String machineLabel; // "Honda PCX160"
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
    this.resolutions = const [],
  });

  final String itemId;
  final String refNo; // balloon label
  final double x; // normalized 0..1 on the stored image
  final double y;
  final String? partName;
  final String? primaryNumber;

  /// This position's item_resolutions (unfiltered — the UI applies the
  /// fitment). Empty when the position has no resolution rows.
  final List<ItemResolutionView> resolutions;

  /// False when a fitment is active, the position has resolutions, and none
  /// of them apply — i.e. this part is not used on the customer's bike.
  bool appliesTo(Fitment fitment) {
    if (!fitment.isActive || resolutions.isEmpty) return true;
    return resolutions.any((r) => r.appliesTo(fitment));
  }
}
