// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:sketch_app/models/drawing_model.dart';

class SketchPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final List<TextElement> textElements;

  SketchPainter(
      {required this.points, required this.color, required this.textElements});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i], points[i + 1], paint);
      }
    }

    for (TextElement textElement in textElements) {
      final textSpan =
          TextSpan(text: textElement.text, style: textElement.style);
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: double.infinity);
      textPainter.paint(canvas, textElement.position);
    }
  }

  @override
  bool shouldRepaint(SketchPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.textElements != textElements;
  }
}
