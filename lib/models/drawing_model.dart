import 'package:flutter/material.dart';

class DrawingModel {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final String? text;
  final TextStyle? textStyle;
  final Offset? textPosition;

  DrawingModel({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.text,
    this.textStyle,
    this.textPosition,
  });
}

class TextElement {
  final String text;
  final Offset position;
  final TextStyle style;

  TextElement(this.text, this.position, this.style);
}

abstract class DrawingAction {}

class DrawAction extends DrawingAction {
  final Offset point;
  DrawAction(this.point);
}

class AddTextAction extends DrawingAction {
  final TextElement textElement;
  AddTextAction(this.textElement);
}
