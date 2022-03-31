import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:openroadmap/export/exporter.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/user_story.dart';
import 'package:openroadmap/provider/backend_provider_interface.dart';

class PlantUMLExporter extends StatefulWidget implements Exporter {
  @override
  void export(BackendProviderInterface orProvider) async {
    // Create Gantt Chart String
    String plantuml = '@startuml\n';
    plantuml += 'projectscale quarterly zoom 4\n';
    String defaultStyle = '<style>' +
        '\nganttDiagram {' +
        '\ntask ' +
        '{\nFontName Arial\nFontColor black\nFontSize 18\nFontStyle bold\nBackGroundColor #b3b3b3\nLineColor black\n}' +
        '\narrow ' +
        '{\nFontName Arial\nFontColor black\nFontSize 18\nFontStyle bold\nBackGroundColor black\nLineColor black\n}' +
        '\n}' +
        '\n</style>\n';
    String userDefinedStyle = orProvider.rm.userDefinedStyle;
    // Set user defined style instead of default
    if (userDefinedStyle != '') {
      plantuml += userDefinedStyle;
    } else {
      plantuml += defaultStyle;
    }
    String content = '';
    DateTime earliest = DateTime(9999, 12, 31);
    for (Release r in orProvider.rm.releases) {
      // Check which release is earliest
      if (r.startDate.isBefore(earliest)) {
        earliest = r.startDate;
      }

      // Set Release start and end date
      content +=
          '[{${r.id}} ${r.name}] as [{${r.id}} ${r.name}] starts ${r.startDate.year}-${r.startDate.month}-${r.startDate.day} '
          'and ends ${r.targetDate.year}-${r.targetDate.month}-${r.targetDate.day}';
      content += '\n';

      // Add information about all user stories
      UserStory? prev;
      for (UserStory wp in r.userStories) {
        if (prev == null) {
          content +=
              '[{${r.id}} ${wp.name}] as [{${r.id}} ${wp.name}] starts at [{${r.id}} ${r.name}]\'s start '
              'and lasts ${r.getDurationFromStoryPoints(wp.storyPoints).inDays} days';
          prev = wp;
        } else {
          content +=
              '[{${r.id}} ${wp.name}] as [{${r.id}} ${wp.name}] starts at [{${r.id}} ${prev.name}]\'s end '
              'and lasts ${r.getDurationFromStoryPoints(wp.storyPoints).inDays} days';
          prev = wp;
        }

        content += '\n';
      }
    }
    plantuml +=
        'Project starts ${earliest.year}-${earliest.month}-${earliest.day}\n';
    plantuml += content;
    plantuml += '@enduml';
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
