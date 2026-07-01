import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemo_clerk/app.dart';
import 'package:wemo_clerk/core/db/app_database.dart';
import 'package:wemo_clerk/core/images/image_store.dart';
import 'package:wemo_clerk/core/settings/app_settings.dart';
import 'package:wemo_clerk/features/home/home_shell.dart';
import 'package:wemo_clerk/features/search/part_detail_screen.dart';
import 'package:wemo_clerk/features/sync/sync_controller.dart';
import 'package:wemo_clerk/features/sync/sync_screen.dart';

/// On-device M1+M2+M3 verification against a seeded, running backend
/// (http://10.0.2.2:8787 = wrangler dev on the PC):
///   flutter test integration_test/sync_test.dart -d emulator-5554
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Tap a bottom-nav destination unambiguously (offstage tabs share labels).
  Finder navTab(String label) =>
      find.descendant(of: find.byType(NavigationBar), matching: find.text(label));

  Future<void> pumpUntil(WidgetTester tester, Finder finder, {int tries = 60}) async {
    for (var i = 0; i < tries && finder.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('sync catalog+image, look up a number, then jump to its dot', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = AppSettings(prefs);
    final db = AppDatabase();
    final imageStore = ImageStore();

    await tester.pumpWidget(WemoClerkApp(db: db, settings: settings, imageStore: imageStore));
    await tester.pumpAndSettle();

    // --- Sync tab: force full sync -----------------------------------------
    await tester.tap(navTab('Sync'));
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

    // --- Search tab: resolve the seeded part number ------------------------
    await tester.tap(navTab('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('searchField')), '12251-KVY-900');
    await pumpUntil(tester, find.text('Cylinder Head Gasket'));
    expect(find.text('Cylinder Head Gasket'), findsWidgets, reason: 'search returned no hit');

    await tester.tap(find.text('Cylinder Head Gasket').first);
    await pumpUntil(tester, find.byType(PartDetailScreen));
    // Part detail: color variant (full number) + local alias resolved offline.
    await pumpUntil(tester, find.text('12251-KVY-900ZE'));
    expect(find.text('12251-KVY-900ZE'), findsOneWidget, reason: 'color variant missing');
    expect(find.text('paking kepala silinder'), findsOneWidget, reason: 'alias missing');

    // --- Appears in: jump to the diagram with the dot highlighted ----------
    final placement = find.descendant(
      of: find.byType(PartDetailScreen),
      matching: find.text('E-1 · Cylinder Head'),
    );
    expect(placement, findsOneWidget, reason: 'placement not listed');
    await tester.tap(placement);
    await pumpUntil(tester, find.text('1'));
    expect(find.text('1'), findsWidgets, reason: 'balloon dot (refNo 1) not rendered');

    // --- Assistant tab: read-only chat (stub backend) with a part citation --
    // Pop the pushed routes (diagram + part detail) back to the shell reliably.
    Navigator.of(tester.element(find.byType(HomeShell))).popUntil((r) => r.isFirst);
    await tester.pumpAndSettle();

    await tester.tap(navTab('Assistant'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('assistantInput')), 'paking');
    await tester.tap(find.byIcon(Icons.send));

    const chip = 'Cylinder Head Gasket · 12251-KVY-900';
    await pumpUntil(tester, find.text(chip));
    expect(find.text(chip), findsWidgets, reason: 'assistant reply/citation missing');

    await tester.tap(find.text(chip).first);
    await pumpUntil(tester, find.byType(PartDetailScreen));
    expect(find.byType(PartDetailScreen), findsOneWidget, reason: 'citation did not open part detail');

    await db.close();
  });
}
