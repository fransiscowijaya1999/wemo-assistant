import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/catalog_repository.dart';
import 'machine_browse_screen.dart';
import 'models.dart';

/// Browse tab root: pick a machine, then browse its diagrams by group.
class MachineListScreen extends StatelessWidget {
  const MachineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<CatalogRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Browse — Machines')),
      body: StreamBuilder<List<MachineListItem>>(
        stream: repo.watchMachines(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final machines = snap.data!;
          if (machines.isEmpty) return const _Empty();
          return ListView.separated(
            itemCount: machines.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = machines[i];
              final year = m.yearLabel;
              final total = m.engineCount + m.frameCount;
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.two_wheeler)),
                title: Text(m.label),
                subtitle: Text([
                  ?year,
                  '$total diagram${total == 1 ? '' : 's'}',
                ].join(' · ')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MachineBrowseScreen(machine: m)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            const Text(
              'No machines yet.\nOpen the Sync tab and pull the catalog.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
