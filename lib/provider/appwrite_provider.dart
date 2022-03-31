import 'dart:convert';
import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/roadmap.dart';
import 'package:openroadmap/model/user.dart';
import 'package:openroadmap/model/user_story.dart';
import 'package:openroadmap/provider/backend_provider_interface.dart';

class AppwriteProvider with ChangeNotifier implements BackendProviderInterface {
  Client client = Client();

  Future? session;
  bool loginInProgress = false;

  late Roadmap rm;

  late Future<Roadmap> frm;

  AppwriteProvider() {
    frm = Future.delayed(
      Duration(seconds: 50),
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

    client
        .setEndpoint('http://localhost/v1')
        .setProject('62408183b8986e2ee510')
        .setSelfSigned();
  }

  Future<dynamic> registerUser(String email, String password) async {
    Account account = Account(client);
    Future result =
        account.create(userId: 'unique()', email: email, password: password);
    result.then((response) {
      login(email, password);
    }).catchError((error) {
      print(error.response);
    });
    return this.session;
  }

  Future<dynamic> login(String email, String password) async {
    this.loginInProgress = true;
    Account account = Account(client);
    this.session = account.createSession(email: email, password: password);

    this.session!.then((value) {
      loginInProgress = false;
    }).catchError((error) {
      print(error.response);
      loginInProgress = false;
    });

    return this.session;
  }

  Future<dynamic> logout() async {
    Account account = Account(client);
    this.session = account.deleteSession(sessionId: 'current');

    this.session!.then((value) {}).catchError((error) {
      print(error.response);
    });

    return this.session;
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

  @override
  rebuild() {
    notifyListeners();
  }
}
