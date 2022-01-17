import 'package:flutter/material.dart';

class ORTheme {
  static double tileHeight = 100;
  static double headerHeight = 80;
  static double tileWidth = 300;

  static Color backgroundColor = Colors.white;

  static ThemeData getTheme() {
    return ThemeData(
      backgroundColor: backgroundColor,
    );
  }
}
