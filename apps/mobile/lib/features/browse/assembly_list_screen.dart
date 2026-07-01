import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/catalog_repository.dart';
import 'diagram_screen.dart';
import 'models.dart';

/// Browse tab: every assembly in the replica; tap one to open its diagram.
/// (A later slice groups these by machine → engine/frame → grid.)
class AssemblyListScreen extends StatelessWidget {
  const AssemblyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<CatalogRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Browse — Diagrams')),
      body: StreamBuilder<List<AssemblyListItem>>(
        stream: repo.watchAssemblies(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          if (items.isEmpty) return const _Empty();
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final a = items[i];
              return ListTile(
                leading: CircleAvatar(
                  child: Icon(a.groupType == 'engine' ? Icons.settings_suggest : Icons.two_wheeler),
                ),
                title: Text('${a.code} · ${a.name}'),
                subtitle: Text('${a.machineLabel} · ${a.groupType}'),
                trailing: Icon(
                  a.hasImage ? Icons.image_outlined : Icons.hide_image_outlined,
                  color: a.hasImage ? null : Theme.of(context).disabledColor,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => DiagramScreen(assemblyId: a.id)),
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
              'No assemblies yet.\nOpen the Sync tab and pull the catalog.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
