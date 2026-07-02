// Frame-serial comparison for item_resolutions serial ranges.
// Dart port of apps/backend/src/lib/serial.ts — keep the two in sync.
//
// Rule: when BOTH values are all-digits (after trim) compare numerically,
// otherwise case-insensitive lexicographic. Honda frame serials in the
// catalogs are all-digit, so the numeric path dominates.

final _allDigits = RegExp(r'^\d+$');

int compareSerial(String a, String b) {
  final ta = a.trim();
  final tb = b.trim();
  if (_allDigits.hasMatch(ta) && _allDigits.hasMatch(tb)) {
    return BigInt.parse(ta).compareTo(BigInt.parse(tb));
  }
  return ta.toLowerCase().compareTo(tb.toLowerCase());
}

/// True when [serial] falls inside [from, to]; a null bound is open on that side.
bool serialInRange(String serial, String? from, String? to) {
  if (from != null && compareSerial(serial, from) < 0) return false;
  if (to != null && compareSerial(serial, to) > 0) return false;
  return true;
}

/// Human label for a resolution's applicability, e.g. "CBS · s/n 1000001–1099999".
/// Null when unrestricted (fits every variant and serial).
String? applicabilityLabel({String? variantName, String? serialFrom, String? serialTo}) {
  final parts = <String>[
    ?variantName,
    if (serialFrom != null || serialTo != null) 's/n ${serialFrom ?? ''}–${serialTo ?? ''}',
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}
