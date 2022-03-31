import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/roadmap.dart';
import 'package:openroadmap/model/user.dart';
import 'package:openroadmap/model/user_story.dart';
import 'package:openroadmap/provider/backend_provider_interface.dart';

class DesktopProvider with ChangeNotifier implements BackendProviderInterface {
  late Roadmap rm;

  late Future<Roadmap> frm;

  DesktopProvider() {
    frm = Future.delayed(
      Duration(seconds: 0),
      () => Roadmap(
        name: 'Roadmap',
        storyPointsPerSprint: 10,
        sprintLength: Duration(days: 14),
        releases: List<Release>.empty(growable: true),
        users: List<User>.empty(growable: true),
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
        roadmapSpecVersion: 1,
      ),
    ).then((value) => this.rm = value);
  }

  @override
  Release getReleaseById(int id) {
    for (Release r in rm.releases) {
      if (r.id == id) {
        return r;
      }
    }
    return Release.invalid();
  }

  @override
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

  @override
  void saveRoadmap(BuildContext context) async {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved: $outputFilePath')));
    }
  }

  @override
  void loadRoadmap(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      dialogTitle: 'Load Roadmap',
      lockParentWindow: true,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      rm = Roadmap.fromJson(jsonDecode(file.readAsStringSync()));
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loaded: ${result.files.single.path}')));
      rebuild();
    } else {
      // User canceled the picker
    }
  }

  rebuild() {
    notifyListeners();
  }

  @override
  Future login(String email, String password) {
    // TODO: implement login
    throw UnimplementedError();
  }

  @override
  Future logout() {
    // TODO: implement logout
    throw UnimplementedError();
  }

  @override
  Future registerUser(String email, String password) {
    // TODO: implement registerUser
    throw UnimplementedError();
  }
}
