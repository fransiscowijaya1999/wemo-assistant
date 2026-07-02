import 'dart:io';

import 'package:flutter/material.dart';

import 'models.dart';

/// Renders a diagram image with balloon dots overlaid at their normalized
/// (0..1) positions. Pinch-zoom/pan via [InteractiveViewer], plus double-tap
/// to zoom in on a spot (and again to reset). Dots move with the image but are
/// inverse-scaled to keep a constant screen size, so zooming into a clump
/// spreads them apart instead of blowing each one up. Tapping a dot (or a row
/// elsewhere) drives [selectedItemId] — every dot of the selected position is
/// highlighted.
class DiagramView extends StatefulWidget {
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
  State<DiagramView> createState() => _DiagramViewState();
}

class _DiagramViewState extends State<DiagramView> {
  final _transform = TransformationController();
  Offset _doubleTapLocal = Offset.zero;

  static const double _doubleTapScale = 3;
  static const double _maxScale = 8;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (_transform.value.getMaxScaleOnAxis() > 1.01) {
      _transform.value = Matrix4.identity();
      return;
    }
    // Zoom in about the tapped point (its scene position stays under the finger).
    final scene = _transform.toScene(_doubleTapLocal);
    _transform.value = Matrix4.identity()
      ..translateByDouble(
          -scene.dx * (_doubleTapScale - 1), -scene.dy * (_doubleTapScale - 1), 0, 1)
      ..scaleByDouble(_doubleTapScale, _doubleTapScale, _doubleTapScale, 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Fit the image inside the available box, preserving aspect ratio.
        var w = constraints.maxWidth;
        var h = w / widget.aspectRatio;
        if (constraints.maxHeight.isFinite && h > constraints.maxHeight) {
          h = constraints.maxHeight;
          w = h * widget.aspectRatio;
        }

        return Center(
          child: GestureDetector(
            onDoubleTapDown: (d) => _doubleTapLocal = d.localPosition,
            onDoubleTap: _onDoubleTap,
            child: InteractiveViewer(
              transformationController: _transform,
              minScale: 1,
              maxScale: _maxScale,
              child: SizedBox(
                width: w,
                height: h,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                        child: Image.file(widget.image, fit: BoxFit.fill, gaplessPlayback: true)),
                    ValueListenableBuilder<Matrix4>(
                      valueListenable: _transform,
                      builder: (context, matrix, _) {
                        final zoom = matrix.getMaxScaleOnAxis();
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            for (final dot in widget.dots)
                              Positioned(
                                left: dot.x * w - _DotMarker.radius,
                                top: dot.y * h - _DotMarker.radius,
                                child: Transform.scale(
                                  scale: 1 / zoom,
                                  child: _DotMarker(
                                    label: dot.refNo,
                                    selected: dot.itemId == widget.selectedItemId,
                                    onTap: () => widget.onTapDot(dot),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
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
