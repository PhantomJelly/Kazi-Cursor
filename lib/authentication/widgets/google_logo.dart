import 'package:flutter/material.dart';

/// Minimal Google "G" mark for the sign-in button.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: const _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final blue = Paint()..color = const Color(0xFF4285F4);
    final red = Paint()..color = const Color(0xFFEA4335);
    final yellow = Paint()..color = const Color(0xFFFBBC05);
    final green = Paint()..color = const Color(0xFF34A853);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.4,
      2.2,
      true,
      blue,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1.8,
      1.4,
      true,
      green,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      3.2,
      1.2,
      true,
      yellow,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      4.4,
      1.6,
      true,
      red,
    );

    final cutout = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.58, cutout);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - radius * 0.18, radius, radius * 0.36),
      blue,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
