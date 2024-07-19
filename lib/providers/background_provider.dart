import 'package:flutter/material.dart';

class BackgroundProvider with ChangeNotifier {
  ImageProvider? _backgroundImage;

  ImageProvider? get backgroundImage => _backgroundImage;

  ///function for saving and updating the background image
  void setBackgroundImage(ImageProvider image) {
    _backgroundImage = image;
    notifyListeners();
  }

  ///clear and remove background image
  void clearBackgroundImage() {
    _backgroundImage = null;
    notifyListeners();
  }
}
