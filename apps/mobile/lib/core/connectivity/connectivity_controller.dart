import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../settings/app_settings.dart';

/// App-wide backend reachability. Probes `GET /health` on start and every
/// [probeInterval] (radio state alone isn't enough — shop wifi can be up
/// while the internet is down). `online == null` means "still checking".
///
/// Read-only concern: this never touches catalog data; it only informs the
/// offline banner and the auto-sync trigger.
class ConnectivityController extends ChangeNotifier {
  ConnectivityController({required this.settings, http.Client? client})
      : _client = client ?? http.Client() {
    probe();
    _timer = Timer.periodic(probeInterval, (_) => probe());
  }

  static const probeInterval = Duration(seconds: 30);

  final AppSettings settings;
  final http.Client _client;
  Timer? _timer;
  bool _probing = false;
  bool _disposed = false;

  bool? online;

  Future<void> probe() async {
    if (_probing) return;
    _probing = true;
    final base = settings.baseUrl.endsWith('/')
        ? settings.baseUrl.substring(0, settings.baseUrl.length - 1)
        : settings.baseUrl;
    bool ok;
    try {
      final res =
          await _client.get(Uri.parse('$base/health')).timeout(const Duration(seconds: 4));
      ok = res.statusCode == 200;
    } catch (_) {
      ok = false;
    }
    _probing = false;
    if (_disposed) return;
    if (online != ok) {
      online = ok;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _client.close();
    super.dispose();
  }
}
