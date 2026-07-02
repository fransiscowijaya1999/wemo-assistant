// Frame-serial comparison for item_resolutions serial ranges.
//
// Rule: when BOTH values are all-digits (after trim) compare numerically, otherwise
// case-insensitive lexicographic. Honda frame serials in the catalogs are all-digit,
// so the numeric path dominates; the lexicographic fallback can misorder mixed-width
// alphanumeric serials. Documented in docs/schema.md.

const ALL_DIGITS = /^\d+$/;

export function compareSerial(a: string, b: string): number {
  const ta = a.trim();
  const tb = b.trim();
  if (ALL_DIGITS.test(ta) && ALL_DIGITS.test(tb)) {
    const na = BigInt(ta);
    const nb = BigInt(tb);
    return na < nb ? -1 : na > nb ? 1 : 0;
  }
  const la = ta.toLowerCase();
  const lb = tb.toLowerCase();
  return la < lb ? -1 : la > lb ? 1 : 0;
}

/** True when serial falls inside [from, to]; a null bound is open on that side. */
export function serialInRange(serial: string, from: string | null, to: string | null): boolean {
  if (from !== null && compareSerial(serial, from) < 0) return false;
  if (to !== null && compareSerial(serial, to) > 0) return false;
  return true;
}
