import 'package:flutter/foundation.dart';

import '../../core/db/app_database.dart';
import '../../core/settings/app_settings.dart';
import 'data/sync_api.dart';
import 'data/sync_repository.dart';

enum SyncStatus { idle, syncing, success, error }

/// Drives the delta-sync loop and exposes state for the sync screen.
///
/// The read-only replica pulls pages until `hasMore` is false, persisting the
/// cursor after each page (partial progress survives a crash; pages are
/// idempotent). Nothing here ever writes back to the backend.
class SyncController extends ChangeNotifier {
  SyncController({required this.db, required this.settings}) : _repo = SyncRepository(db) {
    _load();
  }

  final AppDatabase db;
  final AppSettings settings;
  final SyncRepository _repo;

  SyncStatus status = SyncStatus.idle;
  String? errorMessage;
  int pagesPulled = 0;
  int rowsPulled = 0;
  DateTime? lastSyncedAt;
  Map<String, int> tableCounts = const {};

  Future<void> _load() async {
    lastSyncedAt = await _repo.lastSyncedAt();
    tableCounts = await db.tableCounts();
    notifyListeners();
  }

  Future<void> refreshCounts() async {
    tableCounts = await db.tableCounts();
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (status == SyncStatus.syncing) return;
    status = SyncStatus.syncing;
    errorMessage = null;
    pagesPulled = 0;
    rowsPulled = 0;
    notifyListeners();

    final api = SyncApi(baseUrl: settings.baseUrl);
    try {
      var cursor = await _repo.currentCursor();
      while (true) {
        final page = await api.fetch(cursor: cursor);
        await _repo.applyPage(page.tables);
        cursor = page.cursor;
        await _repo.saveCursor(cursor);

        pagesPulled++;
        rowsPulled += page.tables.values.fold<int>(0, (sum, rows) => sum + rows.length);
        notifyListeners();

        if (!page.hasMore) break;
      }
      await _repo.markSynced(DateTime.now());
      lastSyncedAt = await _repo.lastSyncedAt();
      tableCounts = await db.tableCounts();
      status = SyncStatus.success;
    } catch (e) {
      errorMessage = e is SyncApiException ? e.message : '$e';
      status = SyncStatus.error;
    } finally {
      api.dispose();
      notifyListeners();
    }
  }

  /// Reset the cursor and pull the whole catalog again (recovery path).
  Future<void> forceFullSync() async {
    if (status == SyncStatus.syncing) return;
    await _repo.resetCursor();
    await syncNow();
  }
}
