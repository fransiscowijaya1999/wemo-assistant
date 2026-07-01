import 'dart:io';

import 'package:flutter/material.dart';

import 'models.dart';

/// Renders a diagram image with balloon dots overlaid at their normalized
/// (0..1) positions. Pinch-zoom/pan via [InteractiveViewer]; dots are children
/// of the transformed subtree so they move with the image. Tapping a dot (or a
/// row elsewhere) drives [selectedItemId] — every dot of the selected position
/// is highlighted.
class DiagramView extends StatelessWidget {
  const DiagramView({
    super.key,
    required this.image,
    required this.aspectRatio,
    required this.dots,
    required this.onTapDot,
    this.selectedItemId,
  });

  final File image;
  final double aspectRatio;
  final List<DiagramDot> dots;
  final ValueChanged<DiagramDot> onTapDot;
  final String? selectedItemId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fit the image inside the available box, preserving aspect ratio.
        var w = constraints.maxWidth;
        var h = w / aspectRatio;
        if (constraints.maxHeight.isFinite && h > constraints.maxHeight) {
          h = constraints.maxHeight;
          w = h * aspectRatio;
        }

        return Center(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 6,
            child: SizedBox(
              width: w,
              height: h,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: Image.file(image, fit: BoxFit.fill, gaplessPlayback: true)),
                  for (final dot in dots)
                    Positioned(
                      left: dot.x * w - _DotMarker.radius,
                      top: dot.y * h - _DotMarker.radius,
                      child: _DotMarker(
                        label: dot.refNo,
                        selected: dot.itemId == selectedItemId,
                        onTap: () => onTapDot(dot),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DotMarker extends StatelessWidget {
  const _DotMarker({required this.label, required this.selected, required this.onTap});

  static const double radius = 14;

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected ? scheme.error : scheme.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: radius * 2,
        height: radius * 2,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1))],
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
