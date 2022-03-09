import 'dart:io';

import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/user_story.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:openroadmap/util/setting_provider.dart';
import 'package:openroadmap/util/storypoint_calculator.dart';

class PlantUmlGenerator {
  static String generatePlantUmlCode(ORProvider orProvider) {
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
              'and lasts ${StoryPointCalculator.getDurationFromStoryPoints(wp.storyPoints, r.sprintLength.inDays, r.storyPointsPerSprint).inDays} days';
          prev = wp;
        } else {
          content +=
              '[{${r.id}} ${wp.name}] as [{${r.id}} ${wp.name}] starts at [{${r.id}} ${prev.name}]\'s end '
              'and lasts ${StoryPointCalculator.getDurationFromStoryPoints(wp.storyPoints, r.sprintLength.inDays, r.storyPointsPerSprint).inDays} days';
          prev = wp;
        }

        content += '\n';
      }
    }
    plantuml +=
        'Project starts ${earliest.year}-${earliest.month}-${earliest.day}\n';
    plantuml += content;
    plantuml += '@enduml';
    return plantuml;
  }

  static Future<Image> generateImageFromPlantUml(
      String plantUmlCode, SettingProvider settingProvider) async {
    // create temporary directory for generation
    var systemTempDir = Directory.systemTemp;
    var dir = await systemTempDir.createTemp('openroadmap-plantuml-');
    var file = File('${dir.path}/puml.txt');
    file.writeAsStringSync(plantUmlCode);
    var result = await Process.run('java', [
      '-jar',
      settingProvider.getPlantUmlJarPath(),
      '-o',
      '${dir.path}/',
      '${file.path}/'
    ]);
    var imageFile = File('${dir.path}/puml.png');

    return Image(image: FileImage(imageFile));
  }
}
