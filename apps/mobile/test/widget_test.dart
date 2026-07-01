import 'package:flutter_test/flutter_test.dart';
import 'package:wemo_clerk/core/settings/app_settings.dart';

void main() {
  test('default base URL targets the emulator host alias', () {
    // 10.0.2.2 is the Android emulator's alias for the dev machine's localhost,
    // so `wrangler dev` on the PC is reachable out of the box.
    expect(AppSettings.defaultBaseUrl, 'http://10.0.2.2:8787');
  });
}
