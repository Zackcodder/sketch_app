import 'package:flutter/material.dart';

class FontOption {
  final String name;
  final TextStyle style;

  FontOption(this.name, this.style);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FontOption &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}
