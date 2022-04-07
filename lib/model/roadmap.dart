import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/user.dart';
import 'package:openroadmap/model/user_story.dart';
import 'package:openroadmap/util/base64_helper.dart';

class Roadmap {
  String name;
  List<Release> releases;
  int storyPointsPerSprint;
  Duration sprintLength;
  List<User> users;
  String userDefinedStyle;
  int roadmapSpecVersion = 2;

  Roadmap({
    required this.name,
    required this.releases,
    required this.storyPointsPerSprint,
    required this.sprintLength,
    required this.users,
    required this.userDefinedStyle,
    required this.roadmapSpecVersion,
  });

  factory Roadmap.empty(String name) {
    return Roadmap(
      name: name,
      releases: List<Release>.empty(growable: true),
      storyPointsPerSprint: 0,
      sprintLength: Duration(days: 0),
      users: List<User>.empty(growable: true),
      userDefinedStyle: '',
      roadmapSpecVersion: 2,
    );
  }

  factory Roadmap.fromJson(var json) {
    List<Release> releases;
    if (json['version'] != null && json['version'] < 2) {
      releases = Release.fromJsonList(
          json['releases'],
          json['version'] != null ? json['version'] : -1,
          json['storyPointsPerSprint'],
          json['sprintLength']);
    } else {
      releases = Release.fromJsonList(json['releases'], json['version'], 0, 0);
    }

    return Roadmap(
      name: json['name'],
      releases: releases,
      storyPointsPerSprint: json['storyPointsPerSprint'],
      sprintLength: Duration(days: json['sprintLength']),
      users: User.fromJsonList(json['users']),
      userDefinedStyle: Base64Helper.decodeString(json['style']),
      roadmapSpecVersion: json['version'] != null ? json['version'] : -1,
    );
  }

  Map<String, dynamic> toJson() {
    List releases = List.empty(growable: true);
    for (Release r in this.releases) {
      releases.add(r.toJson());
    }
    List userList = List.empty(growable: true);
    for (User u in this.users) {
      userList.add(u.toJson());
    }
    return {
      '"name"': '"$name"',
      '"releases"': releases,
      '"storyPointsPerSprint"': storyPointsPerSprint,
      '"sprintLength"': sprintLength.inDays,
      '"users"': userList,
      '"style"': '"${Base64Helper.encodeString(userDefinedStyle)}"',
      '"version"': roadmapSpecVersion,
    };
  }

  int getNextReleaseId() {
    return releases.length + 1;
  }

  void addRelease(Release r) {
    this.releases.add(r);
  }

  void deleteRelease(Release r, context) {
    if (r.userStories.length > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              (Text('Release contains User Stories, removal prevented.'))));
    } else {
      this.releases.remove(r);
    }
  }

  addUser() {
    users.add(
      User(
        id: User.determineHighestUserId(users),
        name: 'New user',
        color: Color.fromARGB(255, 100, 100, 100),
      ),
    );
  }

  bool removeUser(User u, context) {
    bool userInUse = false;
    for (Release r in releases) {
      for (UserStory s in r.userStories) {
        if (s.users.contains(u)) {
          userInUse = true;
        }
      }
    }
    if (userInUse) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: (Text(
              'User "${u.name}" assigned to user story, removal prevented.'))));
      return false;
    } else {
      users.remove(u);
      return true;
    }
  }
}
