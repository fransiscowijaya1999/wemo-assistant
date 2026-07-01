import 'package:flutter/material.dart';

import '../assistant/assistant_screen.dart';
import '../browse/assembly_list_screen.dart';
import '../search/search_screen.dart';
import '../sync/sync_screen.dart';

/// Top-level shell: Browse (diagrams), Search (lookup), Assistant (AI), Sync.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 1; // default to Search — the core clerk workflow

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [AssemblyListScreen(), SearchScreen(), AssistantScreen(), SyncScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Browse'),
          NavigationDestination(icon: Icon(Icons.search), selectedIcon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.smart_toy_outlined), selectedIcon: Icon(Icons.smart_toy), label: 'Assistant'),
          NavigationDestination(icon: Icon(Icons.sync_outlined), selectedIcon: Icon(Icons.sync), label: 'Sync'),
        ],
      ),
    );
  }
}
