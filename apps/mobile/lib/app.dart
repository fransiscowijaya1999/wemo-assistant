import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/db/app_database.dart';
import 'core/images/image_store.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'features/assistant/assistant_controller.dart';
import 'features/browse/data/catalog_repository.dart';
import 'features/home/home_shell.dart';
import 'features/search/data/lookup_repository.dart';
import 'features/sync/sync_controller.dart';

class WemoClerkApp extends StatelessWidget {
  const WemoClerkApp({super.key, required this.db, required this.settings, required this.imageStore});

  final AppDatabase db;
  final AppSettings settings;
  final ImageStore imageStore;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        Provider<AppSettings>.value(value: settings),
        Provider<ImageStore>.value(value: imageStore),
        Provider<CatalogRepository>(create: (_) => CatalogRepository(db)),
        Provider<LookupRepository>(create: (_) => LookupRepository(db)),
        ChangeNotifierProvider<SyncController>(
          create: (_) => SyncController(db: db, settings: settings, imageStore: imageStore),
        ),
        ChangeNotifierProvider<AssistantController>(
          create: (_) => AssistantController(settings: settings),
        ),
      ],
      child: MaterialApp(
        title: 'Wemo Clerk',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeShell(),
      ),
    );
  }
}
