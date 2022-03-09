import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:openroadmap/export/exporter.dart';
import 'package:openroadmap/export/plantuml_generator.dart';
import 'package:openroadmap/util/or_provider.dart';

class PlantUMLExporter extends StatefulWidget implements Exporter {
  @override
  void export(ORProvider orProvider) async {
    var plantuml = PlantUmlGenerator.generatePlantUmlCode(orProvider);
    // Open File Save Dialog
    String? outputFilePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save this roadmap as PlantUML Gantt Chart:',
      fileName: '${orProvider.rm.name.toLowerCase().replaceAll(' ', '')}.txt',
    );
    if (outputFilePath != null) {
      final file = File(outputFilePath);
      file.writeAsStringSync(plantuml);
    }
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
