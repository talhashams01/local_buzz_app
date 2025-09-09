import 'package:flutter/material.dart';

class FontSizeProvider extends ChangeNotifier {
  double _fontSize = 17.0; // Default: Medium

  double get fontSize => _fontSize;

  void setSmall() {
    _fontSize = 14.0;
    notifyListeners();
  }

  void setMedium() {
    _fontSize = 17.0;
    notifyListeners();
  }

  void setLarge() {
    _fontSize = 20.0;
    notifyListeners();
  }
}