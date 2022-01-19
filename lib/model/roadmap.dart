import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/user_story.dart';
import 'package:openroadmap/util/base64_helper.dart';

class Roadmap {
  String name;
  List<Release> releases;
  List<UserStory> unassignedUserStories;
  int storyPointsPerSprint;
  Duration sprintLength;
  List<String> users;
  String userDefinedStyle;

  Roadmap({
    this.name,
    this.releases,
    this.unassignedUserStories,
    this.storyPointsPerSprint,
    this.sprintLength,
    this.users,
    this.userDefinedStyle,
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

  void addRelease(Release r) {
    r.id = releases.length + 1;
    this.releases.add(r);
  }

  void deleteRelease(Release r) {
    this.releases.remove(r);
  }
}
