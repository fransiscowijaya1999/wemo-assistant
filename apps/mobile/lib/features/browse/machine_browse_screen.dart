import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/images/image_store.dart';
import 'data/catalog_repository.dart';
import 'diagram_screen.dart';
import 'models.dart';

/// One machine's diagrams: Engine/Frame toggle over a thumbnail grid.
/// Tapping a tile opens the full diagram with tappable dots.
class MachineBrowseScreen extends StatefulWidget {
  const MachineBrowseScreen({super.key, required this.machine});

  final MachineListItem machine;

  @override
  State<MachineBrowseScreen> createState() => _MachineBrowseScreenState();
}

class _MachineBrowseScreenState extends State<MachineBrowseScreen> {
  late String _group = widget.machine.engineCount > 0 || widget.machine.frameCount == 0
      ? 'engine'
      : 'frame';

  @override
  Widget build(BuildContext context) {
    final repo = context.read<CatalogRepository>();
    return Scaffold(
      appBar: AppBar(title: Text(widget.machine.label)),
      body: StreamBuilder<List<AssemblyTile>>(
        stream: repo.watchMachineAssemblies(widget.machine.id),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final all = snap.data!;
          final tiles = all.where((a) => a.groupType == _group).toList();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'engine',
                      label: Text('Engine (${all.where((a) => a.groupType == 'engine').length})'),
                      icon: const Icon(Icons.settings_suggest),
                    ),
                    ButtonSegment(
                      value: 'frame',
                      label: Text('Frame (${all.where((a) => a.groupType == 'frame').length})'),
                      icon: const Icon(Icons.two_wheeler),
                    ),
                  ],
                  selected: {_group},
                  onSelectionChanged: (s) => setState(() => _group = s.first),
                ),
              ),
              Expanded(
                child: tiles.isEmpty
                    ? Center(child: Text('No $_group diagrams.'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.82,
                        ),
                        itemCount: tiles.length,
                        itemBuilder: (context, i) => _AssemblyCard(tile: tiles[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AssemblyCard extends StatelessWidget {
  const _AssemblyCard({required this.tile});

  final AssemblyTile tile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DiagramScreen(assemblyId: tile.id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _DiagramThumb(assemblyId: tile.id, hasImage: tile.hasImage)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tile.code,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(tile.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cached diagram file rendered as a thumbnail; placeholder when the image
/// hasn't been uploaded or synced yet.
class _DiagramThumb extends StatelessWidget {
  const _DiagramThumb({required this.assemblyId, required this.hasImage});

  final String assemblyId;
  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        hasImage ? Icons.image_outlined : Icons.hide_image_outlined,
        size: 32,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    if (!hasImage) return placeholder;
    return FutureBuilder<File>(
      future: context.read<ImageStore>().fileFor(assemblyId),
      builder: (context, snap) {
        final file = snap.data;
        if (file == null || !file.existsSync()) return placeholder;
        return Container(
          color: Colors.white, // diagrams are black-on-white scans
          alignment: Alignment.center,
          padding: const EdgeInsets.all(4),
          child: Image.file(file, fit: BoxFit.contain, cacheWidth: 440),
        );
      },
    );
  }
}
