import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wemo_clerk/app.dart';
import 'package:wemo_clerk/core/db/app_database.dart';
import 'package:wemo_clerk/core/settings/app_settings.dart';
import 'package:wemo_clerk/features/sync/sync_controller.dart';
import 'package:wemo_clerk/features/sync/sync_screen.dart';

/// On-device M1 verification: the app pulls the seeded catalog from the backend
/// (default URL http://10.0.2.2:8787 = wrangler dev on the PC) into the local
/// drift replica. Run with a booted emulator and the backend seeded + running:
///   flutter test integration_test/sync_test.dart -d emulator-5554
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('force full sync pulls the seeded catalog into the replica', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final settings = AppSettings(prefs);
    final db = AppDatabase();

    await tester.pumpWidget(WemoClerkApp(db: db, settings: settings));
    await tester.pumpAndSettle();

    final controller = Provider.of<SyncController>(
      tester.element(find.byType(SyncScreen)),
      listen: false,
    );

    // Reset cursor + pull everything (idempotent, deterministic across reruns).
    await tester.tap(find.text('Force full sync'));

    // pumpAndSettle can't await the network loop; poll the controller instead.
    final deadline = DateTime.now().add(const Duration(seconds: 40));
    while (controller.status == SyncStatus.idle || controller.status == SyncStatus.syncing) {
      await tester.pump(const Duration(milliseconds: 200));
      if (DateTime.now().isAfter(deadline)) break;
    }

    expect(controller.status, SyncStatus.success, reason: 'sync error: ${controller.errorMessage}');

    // The seed loads exactly one row into each of the 12 non-empty tables.
    final total = controller.tableCounts.values.fold<int>(0, (a, b) => a + b);
    expect(total, greaterThanOrEqualTo(12), reason: 'counts: ${controller.tableCounts}');
    expect(controller.tableCounts['parts'], greaterThanOrEqualTo(1));
    expect(controller.tableCounts['dots'], greaterThanOrEqualTo(1));

    await db.close();
  });
}
