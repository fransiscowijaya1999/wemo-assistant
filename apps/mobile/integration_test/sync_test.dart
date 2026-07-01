import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemo_clerk/app.dart';
import 'package:wemo_clerk/core/db/app_database.dart';
import 'package:wemo_clerk/core/images/image_store.dart';
import 'package:wemo_clerk/core/settings/app_settings.dart';
import 'package:wemo_clerk/features/sync/sync_controller.dart';
import 'package:wemo_clerk/features/sync/sync_screen.dart';

/// On-device M1+M2 verification against a seeded, running backend
/// (http://10.0.2.2:8787 = wrangler dev on the PC):
///   flutter test integration_test/sync_test.dart -d emulator-5554
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sync pulls catalog + image, then the diagram shows its dot', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = AppSettings(prefs);
    final db = AppDatabase();
    final imageStore = ImageStore();

    await tester.pumpWidget(WemoClerkApp(db: db, settings: settings, imageStore: imageStore));
    await tester.pumpAndSettle();

    // --- Sync tab: force full sync -----------------------------------------
    await tester.tap(find.byIcon(Icons.sync_outlined));
    await tester.pumpAndSettle();
    final controller = Provider.of<SyncController>(
      tester.element(find.byType(SyncScreen)),
      listen: false,
    );
    await tester.tap(find.text('Force full sync'));

    final deadline = DateTime.now().add(const Duration(seconds: 60));
    while (controller.status == SyncStatus.idle || controller.status == SyncStatus.syncing) {
      await tester.pump(const Duration(milliseconds: 200));
      if (DateTime.now().isAfter(deadline)) break;
    }
    expect(controller.status, SyncStatus.success, reason: 'sync error: ${controller.errorMessage}');
    expect(controller.tableCounts['dots'], greaterThanOrEqualTo(1), reason: '${controller.tableCounts}');
    expect(controller.imagesFetched, greaterThanOrEqualTo(1), reason: 'no diagram image fetched');
    expect(await imageStore.has('asm1'), isTrue, reason: 'diagram image not cached on disk');

    // --- Browse tab: open the assembly, expect a balloon dot ----------------
    await tester.tap(find.byIcon(Icons.grid_view_outlined));
    await tester.pumpAndSettle();
    expect(find.text('E-1 · Cylinder Head'), findsOneWidget);

    await tester.tap(find.text('E-1 · Cylinder Head'));
    // The diagram loads via a Future (DB + image file); poll for the dot marker.
    for (var i = 0; i < 60 && find.text('1').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('1'), findsWidgets, reason: 'balloon dot (refNo 1) not rendered');

    await db.close();
  });
}
