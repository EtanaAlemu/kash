import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/theme/kash_theme.dart';

/// Compact info icon that shows a pointed callout (dialog-like, not a dialog).
class InfoTipIcon extends StatefulWidget {
  const InfoTipIcon({
    super.key,
    required this.message,
    this.title,
    this.size = 20,
  });

  final String message;
  final String? title;
  final double size;

  @override
  State<InfoTipIcon> createState() => _InfoTipIconState();
}

class _InfoTipIconState extends State<InfoTipIcon> {
  final _iconKey = GlobalKey();
  OverlayEntry? _entry;

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  void _toggle() {
    if (_entry != null) {
      _hide();
      return;
    }

    final box = _iconKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayState = Overlay.of(context);
    final overlayBox = overlayState.context.findRenderObject() as RenderBox?;
    if (box == null || overlayBox == null || !box.hasSize) return;

    final iconTopLeft = box.localToGlobal(Offset.zero, ancestor: overlayBox);
    final iconRect = iconTopLeft & box.size;
    final screen = overlayBox.size;
    final padding = MediaQuery.paddingOf(context);

    _entry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _hide,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            _ScreenClampedCallout(
              iconRect: iconRect,
              screenSize: screen,
              padding: padding,
              title: widget.title,
              message: widget.message,
              onClose: _hide,
            ),
          ],
        );
      },
    );
    overlayState.insert(_entry!);
  }

  @override
  void dispose() {
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: _iconKey,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints.tightFor(
        width: widget.size + 12,
        height: widget.size + 12,
      ),
      tooltip: '',
      onPressed: _toggle,
      icon: Icon(
        Icons.info_outline_rounded,
        size: widget.size,
        color: KashColors.textSecondary,
      ),
    );
  }
}

class _ScreenClampedCallout extends StatefulWidget {
  const _ScreenClampedCallout({
    required this.iconRect,
    required this.screenSize,
    required this.padding,
    required this.message,
    required this.onClose,
    this.title,
  });

  final Rect iconRect;
  final Size screenSize;
  final EdgeInsets padding;
  final String? title;
  final String message;
  final VoidCallback onClose;

  @override
  State<_ScreenClampedCallout> createState() => _ScreenClampedCalloutState();
}

class _ScreenClampedCalloutState extends State<_ScreenClampedCallout> {
  static const _margin = 12.0;
  static const _gap = 8.0;
  static const _arrowH = 8.0;

  Size _size = Size.zero;
  bool _placeBelow = true;
  double _left = 0;
  double _top = 0;
  double _arrowDx = 24;

  double get _safeLeft => widget.padding.left + _margin;
  double get _safeRight =>
      widget.screenSize.width - widget.padding.right - _margin;
  double get _safeTop => widget.padding.top + _margin;
  double get _safeBottom =>
      widget.screenSize.height - widget.padding.bottom - _margin;
  double get _maxWidth => math.min(320, _safeRight - _safeLeft);

  void _reposition(Size size) {
    if (size == Size.zero) return;

    final icon = widget.iconRect;
    final iconCenterX = icon.center.dx;

    var placeBelow = true;
    var top = icon.bottom + _gap;
    if (top + size.height > _safeBottom) {
      final above = icon.top - _gap - size.height;
      if (above >= _safeTop) {
        placeBelow = false;
        top = above;
      } else {
        top = (_safeBottom - size.height).clamp(_safeTop, _safeBottom);
        // Prefer below visually if both clip; still clamp.
        placeBelow = top >= icon.bottom;
      }
    }

    var left = iconCenterX - size.width / 2;
    left = left.clamp(
      _safeLeft,
      math.max(_safeLeft, _safeRight - size.width),
    );
    final arrowDx = (iconCenterX - left).clamp(16.0, size.width - 16);

    if (_size == size &&
        _placeBelow == placeBelow &&
        _left == left &&
        _top == top &&
        _arrowDx == arrowDx) {
      return;
    }

    setState(() {
      _size = size;
      _placeBelow = placeBelow;
      _left = left;
      _top = top;
      _arrowDx = arrowDx;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bubble = DecoratedBox(
      decoration: BoxDecoration(
        color: KashColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: KashColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.title != null) ...[
                    Text(
                      widget.title!,
                      style: const TextStyle(
                        color: KashColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    widget.message,
                    style: const TextStyle(
                      color: KashColors.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: 28,
                height: 28,
              ),
              onPressed: widget.onClose,
              icon: const Icon(
                Icons.close,
                size: 16,
                color: KashColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );

    final arrow = SizedBox(
      height: _arrowH,
      width: _maxWidth,
      child: CustomPaint(
        painter: _CalloutArrowPainter(
          color: KashColors.surfaceElevated,
          tipX: _arrowDx,
          pointUp: _placeBelow,
        ),
      ),
    );

    return Positioned(
      left: _left,
      top: _top,
      child: _MeasureSize(
        onChange: _reposition,
        child: Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _placeBelow ? [arrow, bubble] : [bubble, arrow],
            ),
          ),
        ),
      ),
    );
  }
}

class _MeasureSize extends SingleChildRenderObjectWidget {
  const _MeasureSize({required this.onChange, required super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMeasureSize(onChange);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMeasureSize renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _old;

  @override
  void performLayout() {
    super.performLayout();
    final s = size;
    if (_old != s) {
      _old = s;
      WidgetsBinding.instance.addPostFrameCallback((_) => onChange(s));
    }
  }
}

class _CalloutArrowPainter extends CustomPainter {
  _CalloutArrowPainter({
    required this.color,
    required this.tipX,
    required this.pointUp,
  });

  final Color color;
  final double tipX;
  final bool pointUp;

  @override
  void paint(Canvas canvas, Size size) {
    final x = tipX.clamp(8.0, math.max(8.0, size.width - 8)).toDouble();
    final path = Path();
    if (pointUp) {
      path
        ..moveTo(x - 8, size.height)
        ..lineTo(x, 0)
        ..lineTo(x + 8, size.height)
        ..close();
    } else {
      path
        ..moveTo(x - 8, 0)
        ..lineTo(x, size.height)
        ..lineTo(x + 8, 0)
        ..close();
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CalloutArrowPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.tipX != tipX ||
      oldDelegate.pointUp != pointUp;
}

/// Title row with trailing info tip — use in dialogs instead of long body copy.
class InfoTitle extends StatelessWidget {
  const InfoTitle({
    super.key,
    required this.text,
    required this.tip,
    this.tipTitle,
  });

  final String text;
  final String tip;
  final String? tipTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(text)),
        InfoTipIcon(message: tip, title: tipTitle),
      ],
    );
  }
}
