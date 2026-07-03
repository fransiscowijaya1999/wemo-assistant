import 'package:shared_preferences/shared_preferences.dart';

/// Local settings for the read-only clerk app.
///
/// Sync base URL + the clerk API key. The key is entered by hand on the Sync
/// screen and stored on-device only — nothing is compiled into the APK. The
/// URL default targets the Android emulator's host alias (10.0.2.2 == the dev
/// machine's localhost) so `wrangler dev` on the PC is reachable out of the
/// box; point it at the deployed Worker for real use.
class AppSettings {
  AppSettings(this._prefs);

  final SharedPreferences _prefs;

  static const _kBaseUrl = 'sync.baseUrl';
  static const _kApiKey = 'sync.apiKey';
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

  /// Clerk read key (backend CLERK_TOKEN). Empty = not set — the backend will
  /// reject /sync and /chat with 401 until one is entered.
  String get apiKey => _prefs.getString(_kApiKey)?.trim() ?? '';

  Future<void> setApiKey(String value) async {
    final v = value.trim();
    if (v.isEmpty) {
      await _prefs.remove(_kApiKey);
    } else {
      await _prefs.setString(_kApiKey, v);
    }
  }
}
