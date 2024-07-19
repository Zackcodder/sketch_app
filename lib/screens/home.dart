import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sketch_app/providers/background_provider.dart';
import 'package:sketch_app/providers/drawing_provider.dart';
import 'package:sketch_app/screens/color_change_screen.dart';
import 'package:sketch_app/widgets/sketch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final drawingProvider = Provider.of<DrawingProvider>(context);
    final backgroundProvider = Provider.of<BackgroundProvider>(context);
    final picker = ImagePicker();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Sketch App'),
        actions: [
          ///undo
          IconButton(
            icon: const Icon(FontAwesomeIcons.rotateLeft),
            onPressed: () => context.read<DrawingProvider>().undo(),
          ),

          ///clear the canvas
          IconButton(
            icon: const Icon(FontAwesomeIcons.eraser),
            onPressed: () {
              drawingProvider.clearCanvas();
            },
          ),
        ],
      ),
      body: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          const SketchScreen(),
          SizedBox(
            width: 250,
            child: Column(
              children: [
                //the slider for stroke width thickness
                const Text('Stroke Width'),
                Slider(
                  value: drawingProvider.strokeWidth,
                  min: 1.0,
                  max: 10.0,
                  onChanged: (value) {
                    drawingProvider.updateStrokeWidth(value);
                  },
                ),
              ],
            ),
          ),

          ///drawing colors selection
          Positioned(
            left: 5,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 5),
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    FontAwesomeIcons.paintbrush,
                    color: Colors.yellow,
                    size: 20,
                  ),
                  const ColorChangeScreen(),

                  ///font selection
                  IconButton(
                    icon: const Icon(
                      Icons.text_fields,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      await drawingProvider.promptForText(
                          context, drawingProvider);
                    },
                  ),
                ],
              ),
            ),
          ),

          ///saving and loading of drawing
          Positioned(
            right: 0,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ///save file
                Row(
                  children: [
                    const Text('Save'),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.solidFloppyDisk),
                      onPressed: () async {
                        final filename =
                            await drawingProvider.promptForFilename(context);
                        if (filename != null) {
                          await drawingProvider.saveDrawing(filename);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Drawing saved!'),
                          ));
                        }
                      },
                    ),
                  ],
                ),

                ///open file
                Row(
                  children: [
                    const Text('Open File'),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.folderOpen),
                      onPressed: () async {
                        final savedDrawings =
                            await drawingProvider.getSavedDrawings();
                        final selectedFile = await drawingProvider
                            .selectSavedDrawing(context, savedDrawings);
                        if (selectedFile != null) {
                          await drawingProvider.loadDrawing(selectedFile);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Drawing loaded!'),
                          ));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          ///background color  and image selection
          Positioned(
            right: 5,
            top: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    FontAwesomeIcons.brush,
                    color: Colors.amber,
                  ),

                  ///white
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: () {
                      drawingProvider.setBackgroundColor(Colors.white);
                    },
                    color: Colors.white,
                  ),

                  ///yellow
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: () {
                      drawingProvider.setBackgroundColor(Colors.yellow);
                    },
                    color: Colors.yellow,
                  ),

                  ///green
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: () {
                      drawingProvider.setBackgroundColor(Colors.green);
                    },
                    color: Colors.green,
                  ),

                  ///black
                  IconButton(
                    icon: const Icon(Icons.color_lens),
                    onPressed: () {
                      drawingProvider.setBackgroundColor(Colors.black);
                    },
                    color: Colors.black,
                  ),

                  /// add background image
                  IconButton(
                    icon: const Icon(
                      FontAwesomeIcons.image,
                      color: Color.fromARGB(255, 4, 96, 245),
                    ),
                    onPressed: () async {
                      final pickedFile =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        backgroundProvider.setBackgroundImage(
                            FileImage(File(pickedFile.path)));
                      }
                    },
                  ),

                  /// remove background image
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outlined,
                      color: Color.fromARGB(255, 4, 96, 245),
                    ),
                    onPressed: () async {
                      backgroundProvider.clearBackgroundImage();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
