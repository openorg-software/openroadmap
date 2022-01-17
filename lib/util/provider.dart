import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/roadmap.dart';
import 'package:openroadmap/model/workpackage.dart';

class ORProvider extends ChangeNotifier {
  Roadmap rm = Roadmap(
    name: 'Roadmap',
    storyPointsPerSprint: 10,
    sprintLength: Duration(days: 14),
    releases: List<Release>.empty(growable: true),
  );

  Release getReleaseById(String id) {
    for (Release r in rm.releases) {
      if (r.id == id) {
        return r;
      }
    }
    return Release.invalid();
  }

  Workpackage getWorkpackageInReleaseById(
      String releaseId, String workpackageId) {
    for (Release r in rm.releases) {
      if (r.id == releaseId) {
        for (Workpackage w in r.workpackages) {
          if (w.id == workpackageId) {
            return w;
          }
        }
      }
    }
    return Workpackage.invalid();
  }

  void saveRoadmap() async {
    rm.releases = rm.releases;
    String outputFilePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save this roadmap:',
      fileName: 'roadmap.json',
    );
    final file = File(outputFilePath);
    file.writeAsStringSync(rm.toJson().toString());
  }

  void loadRoadmap() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path);
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

  static final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static Random _rnd = Random();

  static String getRandomString(int length) =>
      String.fromCharCodes(Iterable.generate(
          length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  static String getUniqueWorkpackageId() {
    return getRandomString(32);
  }

  static String getUniqueReleaseId() {
    return getRandomString(32);
  }
}
