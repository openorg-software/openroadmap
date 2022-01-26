import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  static double tileHeight = 120;
  static double tileWidth = 350;
  static double headerHeight = 90;

  bool darkMode = false;

  void toggleDarkMode() {
    darkMode = !darkMode;
    notifyListeners();
  }

  ThemeData getTheme() {
    if (darkMode) {
      return getDarkModeTheme();
    } else {
      return getLightModeTheme();
    }
  }

  ThemeData getLightModeTheme() {
    return ThemeData(
      cardTheme: CardTheme(
        color: Color(0xFFDEDEDE),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  ThemeData getDarkModeTheme() {
    return ThemeData(
      cardTheme: CardTheme(
        color: Color(0xFF535353),
      ),
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: Colors.black26,
        onPrimary: Colors.white,
        secondary: Colors.amber,
        onSecondary: Colors.green,
        error: Colors.red,
        onError: Colors.blue,
        background: Colors.black26,
        onBackground: Colors.purple,
        surface: Colors.black45,
        onSurface: Colors.white,
        tertiary: Colors.grey,
        outline: Colors.grey,
      ),
      sliderTheme: SliderThemeData(
        activeTickMarkColor: Colors.black,
        activeTrackColor: Colors.blueGrey,
        thumbColor: Colors.black,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white70,
        labelStyle: TextStyle(color: Colors.black),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        actionTextColor: Colors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.white70,
        ),
        helperStyle: TextStyle(
          color: Colors.white70,
        ),
        labelStyle: TextStyle(
          color: Colors.white70,
        ),
        floatingLabelStyle: TextStyle(
          color: Colors.white70,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}
