import 'dart:math' as math;

import 'package:flutter/material.dart';

class ArcPainter extends CustomPainter {
  ArcPainter({
    this.sweepAngle = 0,
    this.color = const Color.fromRGBO(255, 174, 20, 1),
  });

  final double startAngle = 3 * math.pi / 2;
  final bool useCenter = true;
  final double sweepAngle;
  final Color color;

  @override
  bool shouldRepaint(ArcPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final Paint _paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.02
      ..style = PaintingStyle.fill;

    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, _paint);
  }
}
