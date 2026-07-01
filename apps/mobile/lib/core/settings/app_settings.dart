import 'package:shared_preferences/shared_preferences.dart';

/// Local, unauthenticated settings for the read-only clerk app.
///
/// Only the sync base URL for now. Default targets the Android emulator's host
/// alias (10.0.2.2 == the dev machine's localhost) so `wrangler dev` on the PC
/// is reachable out of the box; point it at the deployed Worker for real use.
class AppSettings {
  AppSettings(this._prefs);

  final SharedPreferences _prefs;

  static const _kBaseUrl = 'sync.baseUrl';
  static const defaultBaseUrl = 'http://10.0.2.2:8787';

  String get baseUrl {
    final v = _prefs.getString(_kBaseUrl);
    return (v == null || v.trim().isEmpty) ? defaultBaseUrl : v.trim();
  }

  Future<void> setBaseUrl(String value) async {
    final v = value.trim();
    if (v.isEmpty) {
      await _prefs.remove(_kBaseUrl);
    } else {
      await _prefs.setString(_kBaseUrl, v);
    }
  }
}
