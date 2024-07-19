import 'package:flutter/material.dart';

class BackgroundProvider with ChangeNotifier {
  ImageProvider? _backgroundImage;

  ImageProvider? get backgroundImage => _backgroundImage;

  void setBackgroundImage(ImageProvider image) {
    _backgroundImage = image;
    notifyListeners();
  }

  void clearBackgroundImage() {
    _backgroundImage = null;
    notifyListeners();
  }
}
