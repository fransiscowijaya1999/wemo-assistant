import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Most-recently-viewed parts (MRU, capped) — the counter workflow repeats the
/// same handful of lookups, so the empty Search tab surfaces them. Stores only
/// part ids; display data always comes from the live replica, so renames and
/// deletions never show stale rows.
class RecentPartsStore extends ChangeNotifier {
  RecentPartsStore(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'search.recentPartIds';
  static const _max = 15;

  List<String> get ids => _prefs.getStringList(_key) ?? const [];

  Future<void> record(String partId) async {
    final next = [partId, ...ids.where((id) => id != partId)];
    await _prefs.setStringList(_key, next.take(_max).toList());
    notifyListeners();
  }

  Future<void> clear() async {
    await _prefs.remove(_key);
    notifyListeners();
  }
}
