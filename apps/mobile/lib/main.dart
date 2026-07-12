import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/db/app_database.dart';
import 'core/images/image_store.dart';
import 'core/settings/app_settings.dart';
import 'features/search/recent_parts_store.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final prefs = await SharedPreferences.getInstance();
  final settings = AppSettings(prefs);
  final db = AppDatabase();
  final imageStore = ImageStore();
  final recentParts = RecentPartsStore(prefs);
  runApp(WemoClerkApp(db: db, settings: settings, imageStore: imageStore, recentParts: recentParts));
  FlutterNativeSplash.remove();
}
