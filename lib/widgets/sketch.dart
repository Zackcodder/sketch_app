// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketch_app/models/drawing_model.dart';
import 'package:sketch_app/providers/background_provider.dart';
import 'package:sketch_app/providers/drawing_provider.dart';

class SketchScreen extends StatefulWidget {
  const SketchScreen({super.key});

  @override
  State<SketchScreen> createState() => _SketchScreenState();
}

class _SketchScreenState extends State<SketchScreen> {
  final List<Offset> _points = [];

  @override
  Widget build(BuildContext context) {
    final drawingProvider = Provider.of<DrawingProvider>(context);
    final backgroundProvider = Provider.of<BackgroundProvider>(context);
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _points.add(details.localPosition);
        });
        drawingProvider.addDrawing(DrawingModel(
          points: List.from(_points),
          color: drawingProvider.currentColor,
          strokeWidth: drawingProvider.strokeWidth,
        ));
      },
      onPanEnd: (details) {
        _points.clear();
        drawingProvider.addPoint(const Offset(100, 100));
      },
      child: Stack(
        children: [
          //background color
          Positioned.fill(
            child: Container(
              color: drawingProvider.backgroundColor,
            ),
          ),
          if (backgroundProvider.backgroundImage != null)
            Positioned.fill(
              child: Image(
                image: backgroundProvider.backgroundImage!,
                fit: BoxFit.cover,
              ),
            ),
          Consumer<DrawingProvider>(
            builder: (context, provider, child) {
              return CustomPaint(
                painter: _DrawingPainter(provider.drawings),
                size: Size.infinite,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingModel> drawings;

  _DrawingPainter(this.drawings);

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawing in drawings) {
      final paint = Paint()
        ..color = drawing.color
        ..strokeWidth = drawing.strokeWidth
        ..isAntiAlias = true
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < drawing.points.length - 1; i++) {
        if (drawing.points[i] != null && drawing.points[i + 1] != null) {
          canvas.drawLine(drawing.points[i], drawing.points[i + 1], paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
