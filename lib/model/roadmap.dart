import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/util/base64_helper.dart';

class Roadmap {
  String name;
  List<Release> releases;
  int storyPointsPerSprint;
  Duration sprintLength;
  List<String> users;
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
      users: Base64Helper.decodeListOfStringFromJson(json['users']),
      userDefinedStyle: Base64Helper.decodeString(json['style']),
    );
  }

  Map<String, dynamic> toJson() {
    List releases = List.empty(growable: true);
    for (Release r in this.releases) {
      releases.add(r.toJson());
    }
    List userList = List.empty(growable: true);
    for (String s in this.users) {
      var encodedUser = Base64Helper.encodeString(s);
      userList.add('"$encodedUser"');
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
