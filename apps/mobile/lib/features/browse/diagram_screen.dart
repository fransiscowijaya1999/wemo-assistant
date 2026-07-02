import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/images/image_store.dart';
import 'data/catalog_repository.dart';
import 'diagram_view.dart';
import 'fitment_controller.dart';
import 'fitment_sheet.dart';
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
  _DiagramData({
    required this.meta,
    required this.imageFile,
    required this.aspectRatio,
    required this.dots,
    required this.fitmentAvailable,
  });
  final AssemblyMeta meta;
  final File? imageFile;
  final double aspectRatio;
  final List<DiagramDot> dots;
  final bool fitmentAvailable; // machine has variants or serial-ranged resolutions
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
    final fitmentAvailable = await repo.fitmentAvailable(meta.machineId);
    final file = await store.fileFor(widget.assemblyId);

    File? imageFile;
    var aspect = meta.aspectRatio ?? 1.0;
    if (await file.exists()) {
      imageFile = file;
      if (meta.aspectRatio == null) {
        aspect = await _decodeAspect(file) ?? 1.0;
      }
    }
    return _DiagramData(
      meta: meta,
      imageFile: imageFile,
      aspectRatio: aspect,
      dots: dots,
      fitmentAvailable: fitmentAvailable,
    );
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

  void _openFitmentSheet(_DiagramData data) {
    showFitmentSheet(
      context,
      machineId: data.meta.machineId,
      machineLabel: data.meta.machineLabel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DiagramData?>(
      future: _future,
      builder: (context, snap) {
        final data = snap.data;
        final title = data == null ? 'Diagram' : '${data.meta.code} · ${data.meta.name}';
        final fitment = data == null
            ? const Fitment()
            : context.watch<FitmentController>().fitmentFor(data.meta.machineId);
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              if (data != null && data.fitmentAvailable)
                IconButton(
                  tooltip: "Customer's bike (variant / serial)",
                  icon: fitment.isActive
                      ? Badge(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          smallSize: 8,
                          child: const Icon(Icons.filter_alt),
                        )
                      : const Icon(Icons.filter_alt_outlined),
                  onPressed: () => _openFitmentSheet(data),
                ),
            ],
          ),
          body: switch (snap.connectionState) {
            ConnectionState.done when data == null => const _Centered('Assembly not found.'),
            ConnectionState.done => _body(data!, fitment),
            _ => const Center(child: CircularProgressIndicator()),
          },
        );
      },
    );
  }

  Widget _body(_DiagramData data, Fitment fitment) {
    if (data.imageFile == null) {
      return _Centered(
        'No diagram image for “${data.meta.code}”.\nIt may not be uploaded yet, or sync hasn’t fetched it.',
        icon: Icons.image_not_supported_outlined,
      );
    }
    final dimmed = <String>{
      if (fitment.isActive)
        for (final dot in data.dots)
          if (!dot.appliesTo(fitment)) dot.itemId,
    };
    return Column(
      children: [
        if (fitment.isActive) _FitmentBanner(fitment: fitment, data: data),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: DiagramView(
              image: data.imageFile!,
              aspectRatio: data.aspectRatio,
              dots: data.dots,
              selectedItemId: _selected?.itemId,
              dimmedItemIds: dimmed,
              onTapDot: (d) => setState(() => _selected = d),
            ),
          ),
        ),
        if (_selected != null)
          _SelectedItemCard(
            dot: _selected!,
            fitment: fitment,
            onClose: () => setState(() => _selected = null),
          ),
      ],
    );
  }
}

/// Thin strip showing the active fitment; tap to edit, x to clear.
class _FitmentBanner extends StatelessWidget {
  const _FitmentBanner({required this.fitment, required this.data});

  final Fitment fitment;
  final _DiagramData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.secondaryContainer,
      child: InkWell(
        onTap: () => showFitmentSheet(
          context,
          machineId: data.meta.machineId,
          machineLabel: data.meta.machineLabel,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 4, 6),
          child: Row(
            children: [
              Icon(Icons.filter_alt, size: 16, color: theme.colorScheme.onSecondaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Showing parts for ${fitment.label}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                visualDensity: VisualDensity.compact,
                tooltip: 'Clear',
                onPressed: () =>
                    context.read<FitmentController>().clear(data.meta.machineId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedItemCard extends StatelessWidget {
  const _SelectedItemCard({required this.dot, required this.fitment, required this.onClose});

  final DiagramDot dot;
  final Fitment fitment;
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
                  ..._numbers(theme),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.close), onPressed: onClose, tooltip: 'Clear'),
          ],
        ),
      ),
    );
  }

  /// The position's part numbers. With resolutions we show the actual resolved
  /// number(s) + qty + applicability; an active fitment narrows to the
  /// applicable ones (or explains that none apply). Without resolutions, fall
  /// back to the base part's primary number.
  List<Widget> _numbers(ThemeData theme) {
    if (dot.resolutions.isEmpty) {
      return [
        Text(
          dot.primaryNumber ?? 'No part number',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ];
    }

    final applicable =
        fitment.isActive ? dot.resolutions.where((r) => r.appliesTo(fitment)).toList() : dot.resolutions;

    if (applicable.isEmpty) {
      // Fitment active and nothing matches: say so, then list what it fits.
      return [
        Text(
          'Not used on ${fitment.label}',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        for (final r in dot.resolutions) _resolutionLine(theme, r, dimmed: true),
      ];
    }
    return [
      for (final r in applicable)
        _resolutionLine(theme, r, dimmed: false, showLabel: !fitment.isActive || applicable.length > 1),
    ];
  }

  Widget _resolutionLine(ThemeData theme, ItemResolutionView r,
      {required bool dimmed, bool showLabel = true}) {
    final color = dimmed ? theme.colorScheme.outline : theme.colorScheme.onSurfaceVariant;
    final label = r.label;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: r.partNumberValue ?? 'No part number',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: dimmed ? theme.colorScheme.outline : theme.colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (r.qty != 1)
              TextSpan(
                text: '  ×${r.qty}',
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
            if (showLabel && label != null)
              TextSpan(
                text: '  $label',
                style: theme.textTheme.bodySmall?.copyWith(color: color),
              ),
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
