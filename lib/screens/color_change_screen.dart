import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketch_app/providers/drawing_provider.dart';

class ColorChangeScreen extends StatelessWidget {
  const ColorChangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final drawingProvider = Provider.of<DrawingProvider>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ///black colors
        GestureDetector(
          onTap: () => drawingProvider.updateCurrentColor(Colors.black),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8, top: 8),
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ),

        ///red color
        GestureDetector(
          onTap: () => drawingProvider.updateCurrentColor(Colors.red),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ),

        ///blue
        GestureDetector(
          onTap: () => drawingProvider.updateCurrentColor(Colors.blue),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ),

        ///white
        GestureDetector(
          onTap: () => drawingProvider.updateCurrentColor(Colors.white),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ),

        ///yellow
        GestureDetector(
          onTap: () => drawingProvider.updateCurrentColor(Colors.yellow),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ),
      ],
    );
  }
}
