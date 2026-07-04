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
///
/// [focusDot]/[focusTick]: when the tick changes, the view zooms in on that
/// dot (used by the parts list and the arrive-from-part-detail highlight).
class DiagramView extends StatefulWidget {
  const DiagramView({
    super.key,
    required this.image,
    required this.aspectRatio,
    required this.dots,
    required this.onTapDot,
    this.selectedItemId,
    this.dimmedItemIds = const {},
    this.focusDot,
    this.focusTick = 0,
  });

  final File image;
  final double aspectRatio;
  final List<DiagramDot> dots;
  final ValueChanged<DiagramDot> onTapDot;
  final String? selectedItemId;

  /// Positions greyed out because they don't apply to the active fitment.
  /// Still tappable, so the clerk can see why.
  final Set<String> dimmedItemIds;

  final DiagramDot? focusDot;
  final int focusTick;

  @override
  State<DiagramView> createState() => _DiagramViewState();
}

class _DiagramViewState extends State<DiagramView> {
  final _transform = TransformationController();
  Offset _doubleTapLocal = Offset.zero;
  int _handledFocusTick = 0;

  static const double _doubleTapScale = 3;
  static const double _focusScale = 2.5;
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

  /// Center [dot] in the full [boxW]×[boxH] viewport at [_focusScale], clamped
  /// so the view never pans past the (scaled) viewport edges. The dot's scene
  /// position accounts for the letterbox offset ([dx],[dy]) of the fitted image.
  void _focusOn(
      DiagramDot dot, double w, double h, double dx, double dy, double boxW, double boxH) {
    const s = _focusScale;
    final sceneX = dx + dot.x * w;
    final sceneY = dy + dot.y * h;
    final tx = (boxW / 2 - sceneX * s).clamp(boxW - boxW * s, 0.0);
    final ty = (boxH / 2 - sceneY * s).clamp(boxH - boxH * s, 0.0);
    _transform.value = Matrix4.identity()
      ..translateByDouble(tx, ty, 0, 1)
      ..scaleByDouble(s, s, s, 1);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // The viewport fills the whole available box — so zooming reveals content
        // across the entire area, not just within the fitted image rectangle.
        final boxW = constraints.maxWidth;
        final boxH = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : constraints.maxWidth / widget.aspectRatio;

        // Fit the image inside the box, preserving aspect ratio, then letterbox
        // (center) it — dots and focus math offset by (dx, dy) to match.
        var w = boxW;
        var h = w / widget.aspectRatio;
        if (h > boxH) {
          h = boxH;
          w = h * widget.aspectRatio;
        }
        final dx = (boxW - w) / 2;
        final dy = (boxH - h) / 2;

        if (widget.focusTick != _handledFocusTick) {
          _handledFocusTick = widget.focusTick;
          final dot = widget.focusDot;
          if (dot != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _focusOn(dot, w, h, dx, dy, boxW, boxH);
            });
          }
        }

        return GestureDetector(
          onDoubleTapDown: (d) => _doubleTapLocal = d.localPosition,
          onDoubleTap: _onDoubleTap,
          child: InteractiveViewer(
            transformationController: _transform,
            minScale: 1,
            maxScale: _maxScale,
            child: SizedBox(
              width: boxW,
              height: boxH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: dx,
                    top: dy,
                    width: w,
                    height: h,
                    child: Image.file(widget.image, fit: BoxFit.fill, gaplessPlayback: true),
                  ),
                  ValueListenableBuilder<Matrix4>(
                    valueListenable: _transform,
                    builder: (context, matrix, _) {
                      final zoom = matrix.getMaxScaleOnAxis();
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          for (final dot in widget.dots)
                            Positioned(
                              left: dx + dot.x * w - _DotMarker.hitRadius,
                              top: dy + dot.y * h - _DotMarker.hitRadius,
                              child: Transform.scale(
                                scale: 1 / zoom,
                                child: _DotMarker(
                                  label: dot.refNo,
                                  selected: dot.itemId == widget.selectedItemId,
                                  dimmed: widget.dimmedItemIds.contains(dot.itemId),
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
        );
      },
    );
  }

}

class _DotMarker extends StatelessWidget {
  const _DotMarker({
    required this.label,
    required this.selected,
    required this.dimmed,
    required this.onTap,
  });

  static const double radius = 14;

  /// Tappable radius — larger than the visual dot so shop fingers land it.
  static const double hitRadius = 22;

  final String label;
  final bool selected;
  final bool dimmed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected
        ? scheme.error
        : dimmed
            ? scheme.outline
            : scheme.primary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: hitRadius * 2,
        height: hitRadius * 2,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Container(
          width: radius * 2,
          height: radius * 2,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg.withValues(alpha: dimmed && !selected ? 0.55 : 0.9),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black45, blurRadius: 2, offset: Offset(0, 1))
            ],
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

/// Sort helper: balloon refs are usually numeric ("1", "12"), sometimes not
/// ("B1") — numeric first in value order, then the rest alphabetically.
int compareRefNo(String a, String b) {
  final na = int.tryParse(a);
  final nb = int.tryParse(b);
  if (na != null && nb != null) return na.compareTo(nb);
  if (na != null) return -1;
  if (nb != null) return 1;
  return a.compareTo(b);
}
