import 'package:flutter/material.dart';

class SettingProvider extends ChangeNotifier {
  String plantUmlJarPath = '';
  SettingProvider() {
    // Restore settings from file
  }

  bool isPlantUmlJarPathConfigured = false;

  String getPlantUmlJarPath() {
    return ('G:/Downloads/plantuml-1.2022.2.jar');
  }

  void saveSettings() {}
}
