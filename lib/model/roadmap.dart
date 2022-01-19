import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/user.dart';
import 'package:openroadmap/util/base64_helper.dart';

class Roadmap {
  String name;
  List<Release> releases;
  int storyPointsPerSprint;
  Duration sprintLength;
  List<User> users;
  String userDefinedStyle;

  Roadmap({
    required this.name,
    required this.releases,
    required this.storyPointsPerSprint,
    required this.sprintLength,
    required this.users,
    required this.userDefinedStyle,
  });

  factory Roadmap.fromJson(var json) {
    return Roadmap(
      name: json['name'],
      releases: Release.fromJsonList(json['releases']),
      storyPointsPerSprint: json['storyPointsPerSprint'],
      sprintLength: Duration(days: json['sprintLength']),
      users: User.fromJsonList(json['users']),
      userDefinedStyle: Base64Helper.decodeString(json['style']),
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
    };
  }

  int getNextReleaseId() {
    return releases.length + 1;
  }

  void addRelease(Release r) {
    this.releases.add(r);
  }

  void deleteRelease(Release r) {
    this.releases.remove(r);
  }
}
