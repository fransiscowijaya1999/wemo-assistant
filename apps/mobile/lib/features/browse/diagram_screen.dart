import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/images/image_store.dart';
import 'data/catalog_repository.dart';
import 'diagram_view.dart';
import 'models.dart';

class DiagramScreen extends StatefulWidget {
  const DiagramScreen({super.key, required this.assemblyId, this.highlightItemId});

  final String assemblyId;

  /// When set (e.g. arriving from part detail), the matching position's dots
  /// start highlighted and its part card is shown.
  final String? highlightItemId;

  @override
  State<DiagramScreen> createState() => _DiagramScreenState();
}

class _DiagramData {
  _DiagramData({required this.meta, required this.imageFile, required this.aspectRatio, required this.dots});
  final AssemblyMeta meta;
  final File? imageFile;
  final double aspectRatio;
  final List<DiagramDot> dots;
}

class _DiagramScreenState extends State<DiagramScreen> {
  late final Future<_DiagramData?> _future;
  DiagramDot? _selected;

  @override
  void initState() {
    super.initState();
    // Capture providers before the async gaps.
    _future = _load(context.read<CatalogRepository>(), context.read<ImageStore>());
    if (widget.highlightItemId != null) {
      _future.then((data) {
        if (!mounted || data == null) return;
        for (final dot in data.dots) {
          if (dot.itemId == widget.highlightItemId) {
            setState(() => _selected = dot);
            break;
          }
        }
      });
    }
  }

  Future<_DiagramData?> _load(CatalogRepository repo, ImageStore store) async {
    final meta = await repo.assemblyMeta(widget.assemblyId);
    if (meta == null) return null;
    final dots = await repo.diagramDots(widget.assemblyId);
    final file = await store.fileFor(widget.assemblyId);

    File? imageFile;
    var aspect = meta.aspectRatio ?? 1.0;
    if (await file.exists()) {
      imageFile = file;
      if (meta.aspectRatio == null) {
        aspect = await _decodeAspect(file) ?? 1.0;
      }
    }
    return _DiagramData(meta: meta, imageFile: imageFile, aspectRatio: aspect, dots: dots);
  }

  Future<double?> _decodeAspect(File f) async {
    try {
      final codec = await ui.instantiateImageCodec(await f.readAsBytes());
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final aspect = image.height == 0 ? null : image.width / image.height;
      image.dispose();
      return aspect;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DiagramData?>(
      future: _future,
      builder: (context, snap) {
        final data = snap.data;
        final title = data == null ? 'Diagram' : '${data.meta.code} · ${data.meta.name}';
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: switch (snap.connectionState) {
            ConnectionState.done when data == null => const _Centered('Assembly not found.'),
            ConnectionState.done => _body(data!),
            _ => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }

  Widget _body(_DiagramData data) {
    if (data.imageFile == null) {
      return _Centered(
        'No diagram image for “${data.meta.code}”.\nIt may not be uploaded yet, or sync hasn’t fetched it.',
        icon: Icons.image_not_supported_outlined,
      );
    }
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: DiagramView(
              image: data.imageFile!,
              aspectRatio: data.aspectRatio,
              dots: data.dots,
              selectedItemId: _selected?.itemId,
              onTapDot: (d) => setState(() => _selected = d),
            ),
          ),
        ),
        if (_selected != null)
          _SelectedItemCard(dot: _selected!, onClose: () => setState(() => _selected = null)),
      ],
    );
  }
}

class _SelectedItemCard extends StatelessWidget {
  const _SelectedItemCard({required this.dot, required this.onClose});

  final DiagramDot dot;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              child: Text(dot.refNo, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dot.partName ?? 'Unnamed part', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    dot.primaryNumber ?? 'No part number',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: onClose, tooltip: 'Clear'),
          ],
        ),
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered(this.text, {this.icon});
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(height: 12),
            ],
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
