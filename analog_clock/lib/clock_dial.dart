import 'dart:math' as math;

import 'package:flutter/material.dart';

class TClockDialPainter extends CustomPainter {
  final clockText;

  final hourTickMarkLength = 2.0;
  final quadTickMarkLength = 4.0;
  final minuteTickMarkLength = 1.5;

  final hourTickMarkWidth = 1.2;
  final minuteTickMarkWidth = 0.5;

  final Paint tickPaint;
  final TextPainter textPainter;
  final TextStyle textStyle;

  final romanNumeralList = [
    'XII',
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
    'X',
    'XI'
  ];

  TClockDialPainter({this.clockText = TClockText.arabic})
      : tickPaint = Paint(),
        textPainter = TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        textStyle = const TextStyle(
          color: Color.fromRGBO(53, 0, 71, 1),
          fontSize: 10.0,
        ) {
    tickPaint.color = Color.fromRGBO(53, 0, 71, 1);
    tickPaint.strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var tickMarkLength;
    final angle = 2 * math.pi / 60;
    final radius = size.width / 2;
    canvas.save();

    // drawing
    canvas.translate(radius, radius);
    for (var i = 0; i < 60; i++) {
      //make the length and stroke of the tick marker longer and thicker depending
      tickMarkLength = i % 5 == 0 ? hourTickMarkLength : minuteTickMarkLength;
      tickMarkLength = i % 15 == 0 ? quadTickMarkLength : tickMarkLength;
      tickPaint.strokeWidth =
          i % 5 == 0 ? hourTickMarkWidth : minuteTickMarkWidth;
      canvas.drawLine(Offset(0.0, -radius),
          Offset(0.0, -radius + tickMarkLength), tickPaint);

      //draw the text
      if (i % 5 == 0 && this.clockText != TClockText.none) {
        canvas.save();
        canvas.translate(0.0, -radius + 15.0);

        textPainter.text = TextSpan(
          text: this.clockText == TClockText.roman
              ? '${romanNumeralList[i ~/ 5]}'
              : '${i == 0 ? 12 : i ~/ 5}',
          style: textStyle,
        );

        //helps make the text painted vertically
        canvas.rotate(-angle * i);

        textPainter.layout();

        textPainter.paint(canvas,
            Offset(-(textPainter.width / 2), -(textPainter.height / 2)));

        canvas.restore();
      }

      canvas.rotate(angle);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

enum TClockText { roman, arabic, none }
