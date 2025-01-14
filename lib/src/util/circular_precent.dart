import 'dart:math' as math;

import 'package:flutter/material.dart';

class CircularPercent extends CustomPainter {
  final Color color;
  final Color backgroundColor;
  final double percentage;

  const CircularPercent(
      {required this.percentage,
      required this.color,
      required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 3.0
      ..style = PaintingStyle.fill;

    final double mainCircleDiameter = size.width;

    final arcsRect =
        Rect.fromLTWH(0, 0, mainCircleDiameter, mainCircleDiameter);

    canvas.drawArc(arcsRect, math.pi * 3 / 2, math.pi * 2 * percentage, true,
        paint..color = color);

    canvas.drawArc(arcsRect, math.pi * 2 * (percentage - 0.25),
        math.pi * 2 * (1 - percentage), true, paint..color = backgroundColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
