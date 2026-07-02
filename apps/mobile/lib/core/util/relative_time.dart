/// "42s ago" / "5m ago" / "3h ago" / "2d ago" — coarse relative timestamps
/// for sync freshness labels.
String relativeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inSeconds < 60) return '${d.inSeconds}s ago';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}
