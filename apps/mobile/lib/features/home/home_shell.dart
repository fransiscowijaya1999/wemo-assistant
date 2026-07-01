import 'package:flutter/material.dart';

import '../browse/assembly_list_screen.dart';
import '../sync/sync_screen.dart';

/// Top-level shell with the two M2 destinations: Browse (diagrams) and Sync.
/// (Search / Part detail arrive in later slices.)
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [AssemblyListScreen(), SyncScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Browse'),
          NavigationDestination(icon: Icon(Icons.sync_outlined), selectedIcon: Icon(Icons.sync), label: 'Sync'),
        ],
      ),
    );
  }
}
