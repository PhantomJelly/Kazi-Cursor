import 'package:flutter/material.dart';

/// Plain white hammer — head on the left, handle on the right.
/// Pivot for swing animation: [Alignment.centerRight] (base of handle).
class HammerIcon extends StatelessWidget {
  const HammerIcon({
    super.key,
    this.size = 48,
    this.color = Colors.white,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.38),
      painter: _HammerPainter(color: color),
    );
  }
}

class _HammerPainter extends CustomPainter {
  _HammerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final headWidth = size.width * 0.34;
    final headHeight = size.height;
    final handleWidth = size.width - headWidth;
    final handleHeight = size.height * 0.38;
    final handleTop = (size.height - handleHeight) / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, headWidth, headHeight),
        const Radius.circular(4),
      ),
      paint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(headWidth, handleTop, handleWidth, handleHeight),
        const Radius.circular(3),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
