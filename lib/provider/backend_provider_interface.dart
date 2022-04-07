import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/roadmap.dart';
import 'package:openroadmap/model/user.dart';
import 'package:openroadmap/model/user_story.dart';

abstract class BackendProviderInterface with ChangeNotifier {
  BackendProviderInterface() {
    futureRoadmaps = Future.delayed(
        Duration(seconds: 0), () => List<Roadmap>.empty(growable: true));
  }

  late Roadmap rm;

  Future<Roadmap> frm = Future.delayed(
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
          ));

  late Future<List<Roadmap>> futureRoadmaps;

  /*
  User Management
   */
  Future<dynamic> registerUser(String email, String password);

  Future<dynamic> login(String email, String password);

  Future<dynamic> logout();

  /*
  Business Logic
   */
  void fetchRoadmaps();
  void addRoadmap(Roadmap rm);
  void saveRoadmap(BuildContext context);
  void loadRoadmap(BuildContext context);

  Release getReleaseById(int id);
  UserStory getUserStoryInReleaseById(int releaseId, int userStoryId);

  void addReleaseToRoadmap(
    Release id,
  );
  void updateRelease();
  void deleteRelease();

  void addUserStoryToRelease();
  void removeUserStoryFromRelease();
  void updateUserStory();
  void deleteUserStory();

  /*
  UI
   */
  rebuild();
}
