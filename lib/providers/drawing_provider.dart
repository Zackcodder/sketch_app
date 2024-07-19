import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sketch_app/models/drawing_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sketch_app/models/fonts_options.dart';

class DrawingProvider with ChangeNotifier {
  final List<Offset> _points = [];
  Color _color = Colors.black;
  final List<TextElement> _textElements = [];
  final List<DrawingAction> _actionStack = [];
  List<DrawingModel> _drawings = [];
  Color _currentColor = Colors.black;
  double _strokeWidth = 2.0;

  ///backgroud color
  Color _backgroundColor = Colors.white;
  // Getter for background color
  Color get backgroundColor => _backgroundColor;

  List<DrawingModel> get drawings => _drawings;
  Color get currentColor => _currentColor;
  double get strokeWidth => _strokeWidth;

  Color get color => _color;
  List<Offset> get points => _points;
  List<TextElement> get textElements => _textElements;

  TextStyle _currentTextStyle =
      const TextStyle(fontFamily: 'Arial', fontSize: 20);
  TextStyle get currentTextStyle => _currentTextStyle;

  ///adjust the thickness of the drawing tool
  updateStrokeWidth(double width) {
    _strokeWidth = width;
    notifyListeners();
  }

  // To update the background color
  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
  }

  void setColor(Color color) {
    _color = color;
    notifyListeners();
  }

  void addPoint(Offset point) {
    _points.add(point);
    _actionStack.add(DrawAction(point));
    notifyListeners();
  }

  void clearPoints() {
    _points.clear();
    _textElements.clear();
    _actionStack.clear();
    notifyListeners();
  }

  void addText(String text, Offset position) {
    TextElement textElement = TextElement(text, position, _currentTextStyle);
    _textElements.add(textElement);
    _actionStack.add(AddTextAction(textElement));
    notifyListeners();
  }

  void updateTextStyle(TextStyle style) {
    _currentTextStyle = style;
  }

  void undo() {
    if (_actionStack.isNotEmpty) {
      DrawingAction lastAction = _actionStack.removeLast();
      if (lastAction is DrawAction) {
        _points.removeLast();
      } else if (lastAction is AddTextAction) {
        _textElements.remove(lastAction.textElement);
      }
      notifyListeners();
    }
  }

  void addDrawing(DrawingModel drawing) {
    _drawings.add(drawing);
    notifyListeners();
  }

  void updateCurrentColor(Color color) {
    _currentColor = color;
    notifyListeners();
  }

  void clearCanvas() {
    _drawings.clear();
    notifyListeners();
  }

  Future<String> _getDrawingDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/drawings';
    final dir = Directory(path);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return path;
  }

  Future<void> saveDrawing(String filename) async {
    final path = await _getDrawingDirectory();
    final file = File('$path/$filename.json');
    final drawingsJson = _drawings.map((drawing) {
      return {
        'points': drawing.points
            .map((point) => {'x': point.dx, 'y': point.dy})
            .toList(),
        'color': drawing.color.value,
        'strokeWidth': drawing.strokeWidth,
        'text': drawing.text,
        'textStyle': drawing.textStyle != null
            ? {
                'color': drawing.textStyle!.color!.value,
                'fontSize': drawing.textStyle!.fontSize,
                'fontFamily': drawing.textStyle!.fontFamily,
              }
            : null,
        'textPosition': drawing.textPosition != null
            ? {'x': drawing.textPosition!.dx, 'y': drawing.textPosition!.dy}
            : null,
      };
    }).toList();
    await file.writeAsString(json.encode(drawingsJson));
  }

  Future<void> loadDrawing(String filename) async {
    final path = await _getDrawingDirectory();
    final file = File('$path/$filename.json');
    if (!file.existsSync()) return;

    final contents = await file.readAsString();
    final drawingsJson = json.decode(contents) as List<dynamic>;
    _drawings = drawingsJson.map((drawingJson) {
      final pointsJson = drawingJson['points'] as List<dynamic>;
      final points = pointsJson.map((pointJson) {
        final x = pointJson['x'] as double;
        final y = pointJson['y'] as double;
        return Offset(x, y);
      }).toList();
      final color = Color(drawingJson['color'] as int);
      final strokeWidth = drawingJson['strokeWidth'] as double;
      final text = drawingJson['text'] as String?;
      final textStyleJson = drawingJson['textStyle'] as Map<String, dynamic>?;
      final textStyle = textStyleJson != null
          ? TextStyle(
              color: Color(textStyleJson['color'] as int),
              fontSize: textStyleJson['fontSize'] as double,
              fontFamily: textStyleJson['fontFamily'] as String?,
            )
          : null;
      final textPositionJson =
          drawingJson['textPosition'] as Map<String, dynamic>?;
      final textPosition = textPositionJson != null
          ? Offset(
              textPositionJson['x'] as double, textPositionJson['y'] as double)
          : null;
      return DrawingModel(
        points: points,
        color: color,
        strokeWidth: strokeWidth,
        text: text,
        textStyle: textStyle,
        textPosition: textPosition,
      );
    }).toList();
    notifyListeners();
  }

  Future<List<String>> getSavedDrawings() async {
    final path = await _getDrawingDirectory();
    final dir = Directory(path);
    if (!dir.existsSync()) return [];

    final files = dir
        .listSync()
        .where((entity) => entity is File && entity.path.endsWith('.json'))
        .toList();
    return files
        .map((file) => file.path.split('/').last.split('.').first)
        .toList();
  }

  ///

  Future<String?> promptForFilename(BuildContext context) async {
    String? filename;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Drawing'),
          content: TextField(
            onChanged: (value) {
              filename = value;
            },
            decoration: const InputDecoration(hintText: "Enter file name"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(filename);
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> selectSavedDrawing(
      BuildContext context, List<String> savedDrawings) async {
    String? selectedFile;
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Open Drawing'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: savedDrawings.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(savedDrawings[index]),
                  onTap: () {
                    selectedFile = savedDrawings[index];
                    Navigator.of(context).pop(selectedFile);
                  },
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  ///select font
  Future<void> promptForText(
      BuildContext context, DrawingProvider drawingProvider) async {
    TextEditingController textController = TextEditingController();

    List<FontOption> fontOptions = [
      FontOption(
          'Arial',
          const TextStyle(
              fontFamily: 'Arial', fontSize: 20, color: Colors.black)),
      FontOption(
          'Lobster', GoogleFonts.lobster(fontSize: 20, color: Colors.black)),
      FontOption(
          'Roboto', GoogleFonts.roboto(fontSize: 20, color: Colors.black)),
    ];

    FontOption selectedFontOption = fontOptions.first;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Text'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(hintText: 'Enter text'),
              ),
              DropdownButton<FontOption>(
                value: selectedFontOption,
                items: fontOptions.map((FontOption option) {
                  return DropdownMenuItem<FontOption>(
                    value: option,
                    child: Text(
                      'Sample Text',
                      style: option.style,
                    ),
                  );
                }).toList(),
                onChanged: (FontOption? newOption) {
                  if (newOption != null) {
                    selectedFontOption = newOption;
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.of(context).pop();
                if (textController.text.isNotEmpty) {
                  drawingProvider.updateTextStyle(selectedFontOption.style);
                  drawingProvider.addText(textController.text,
                      const Offset(0, 0)); // Example position
                }
              },
            ),
          ],
        );
      },
    );
  }

  ///
}
