import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/connectivity/connectivity_controller.dart';
import '../../core/util/relative_time.dart';
import '../assistant/assistant_screen.dart';
import '../browse/machine_list_screen.dart';
import '../search/search_screen.dart';
import '../sync/sync_controller.dart';
import '../sync/sync_screen.dart';

/// Top-level shell: Browse (diagrams), Search (lookup), Assistant (AI), Sync.
/// Also owns the app-wide offline strip and the auto-sync trigger: whenever the
/// backend becomes reachable and the replica is stale, a silent delta pull runs
/// so the clerk never has to remember to sync.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _index = 1; // default to Search — the core clerk workflow

  /// Don't auto-sync more often than this; manual "Sync now" is always allowed.
  static const _autoSyncMinGap = Duration(minutes: 15);

  late final ConnectivityController _connectivity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectivity = context.read<ConnectivityController>();
    _connectivity.addListener(_maybeAutoSync);
    // Covers the launch case: the first probe usually completes after this
    // frame and fires the listener; if it already did, check now.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoSync());
  }

  @override
  void dispose() {
    _connectivity.removeListener(_maybeAutoSync);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _connectivity.probe();
  }

  void _maybeAutoSync() {
    if (_connectivity.online != true || !mounted) return;
    final sync = context.read<SyncController>();
    if (sync.status == SyncStatus.syncing) return;
    final last = sync.lastSyncedAt;
    if (last == null || DateTime.now().difference(last) > _autoSyncMinGap) {
      sync.syncNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [MachineListScreen(), SearchScreen(), AssistantScreen(), SyncScreen()],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _OfflineStrip(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Browse'),
              NavigationDestination(icon: Icon(Icons.search), selectedIcon: Icon(Icons.search), label: 'Search'),
              NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy), label: 'Assistant'),
              NavigationDestination(icon: Icon(Icons.sync_outlined), selectedIcon: Icon(Icons.sync), label: 'Sync'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Thin app-wide banner shown while the backend is unreachable. The local
/// replica keeps working; this just tells the clerk why AI/sync won't and how
/// fresh the local copy is. Tapping retries immediately.
class _OfflineStrip extends StatelessWidget {
  const _OfflineStrip();

  @override
  Widget build(BuildContext context) {
    final online = context.watch<ConnectivityController>().online;
    final lastSynced = context.watch<SyncController>().lastSyncedAt;
    final show = online == false;

    final theme = Theme.of(context);
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: !show
          ? const SizedBox(width: double.infinity)
          : Material(
              color: theme.colorScheme.inverseSurface,
              child: InkWell(
                onTap: () => context.read<ConnectivityController>().probe(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_off, size: 18, color: theme.colorScheme.onInverseSurface),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          lastSynced == null
                              ? 'Offline — local catalog is empty; sync when back online'
                              : 'Offline — using local catalog, synced ${relativeAgo(lastSynced)}',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.onInverseSurface),
                        ),
                      ),
                      Icon(Icons.refresh, size: 18, color: theme.colorScheme.onInverseSurface),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
