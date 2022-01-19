import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/roadmap.dart';
import 'package:openroadmap/model/user_story.dart';

class ORProvider extends ChangeNotifier {
  Roadmap rm = Roadmap(
    name: 'Roadmap',
    storyPointsPerSprint: 10,
    sprintLength: Duration(days: 14),
    releases: List<Release>.empty(growable: true),
    users: List<String>.empty(growable: true),
    userDefinedStyle: '<style>\n' +
        '  ganttDiagram {\n' +
        '    task {\n' +
        '    FontName Arial\n' +
        '    FontColor black\n' +
        '    FontSize 18\n' +
        '    FontStyle bold\n' +
        '    BackGroundColor #b3b3b3\n' +
        '    LineColor black\n' +
        '    }\n' +
        '  arrow {\n' +
        '    FontName Arial\n' +
        '    FontColor black\n' +
        '    FontSize 18\n' +
        '    FontStyle bold\n' +
        '    BackGroundColor black\n' +
        '    LineColor black\n' +
        '    }\n' +
        '  }\n' +
        '</style>\n',
  );

  Release getReleaseById(int id) {
    for (Release r in rm.releases) {
      if (r.id == id) {
        return r;
      }
    }
    return Release.invalid();
  }

  UserStory getUserStoryInReleaseById(int releaseId, int userStoryId) {
    for (Release r in rm.releases) {
      if (r.id == releaseId) {
        for (UserStory w in r.userStories) {
          if (w.id == userStoryId) {
            return w;
          }
        }
      }
    }
    return UserStory.invalid();
  }

  void saveRoadmap() async {
    rm.releases = rm.releases;
    String? outputFilePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save this roadmap:',
      fileName: 'roadmap.json',
      allowedExtensions: ['json'],
      type: FileType.custom,
      lockParentWindow: true,
    );
    if (outputFilePath != null) {
      final file = File(outputFilePath);
      file.writeAsStringSync(rm.toJson().toString());
    }
  }

  void loadRoadmap() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      rm = Roadmap.fromJson(jsonDecode(file.readAsStringSync()));
      rebuild();
    } else {
      // User canceled the picker
    }
  }

  Duration getDurationFromStoryPoints(num storyPoints) {
    // Get duration per storypoint
    return Duration(
        days: (storyPoints * (rm.sprintLength.inDays / rm.storyPointsPerSprint))
            .toInt());
  }

  int getStoryPointDifference(DateTime startDate, DateTime endDate) {
    Duration difference;
    if (startDate.isAfter(endDate)) {
      difference = startDate.difference(endDate);
    } else {
      difference = endDate.difference(startDate);
    }
    return (difference.inDays *
            (rm.storyPointsPerSprint / rm.sprintLength.inDays))
        .toInt();
  }

  rebuild() {
    notifyListeners();
  }
}
