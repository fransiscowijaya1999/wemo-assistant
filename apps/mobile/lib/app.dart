import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/db/app_database.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'features/sync/sync_controller.dart';
import 'features/sync/sync_screen.dart';

class WemoClerkApp extends StatelessWidget {
  const WemoClerkApp({super.key, required this.db, required this.settings});

  final AppDatabase db;
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        Provider<AppSettings>.value(value: settings),
        ChangeNotifierProvider<SyncController>(
          create: (_) => SyncController(db: db, settings: settings),
        ),
      ],
      child: MaterialApp(
        title: 'Wemo Clerk',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SyncScreen(),
      ),
    );
  }
}
