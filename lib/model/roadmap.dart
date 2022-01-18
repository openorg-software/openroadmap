import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/workpackage.dart';

class Roadmap {
  String name;
  List<Release> releases;
  List<Workpackage> unassignedWorkpackages;
  int storyPointsPerSprint;
  Duration sprintLength;

  Roadmap(
      {this.name,
      this.releases,
      this.unassignedWorkpackages,
      this.storyPointsPerSprint,
      this.sprintLength});

  factory Roadmap.fromJson(var json) {
    return Roadmap(
        name: json['name'],
        releases: Release.fromJsonList(json['releases']),
        storyPointsPerSprint: json['storyPointsPerSprint'],
        sprintLength: Duration(days: json['sprintLength']));
  }

  Map<String, dynamic> toJson() {
    List releases = List.empty(growable: true);
    for (Release r in this.releases) {
      releases.add(r.toJson());
    }
    return {
      '"name"': '"$name"',
      '"releases"': releases,
      '"storyPointsPerSprint"': storyPointsPerSprint,
      '"sprintLength"': sprintLength.inDays
    };
  }

  void addRelease(Release r) {
    r.id = releases.length + 1;
    print('New release: ${r.id}');
    print('New release: ${this.releases}');
    this.releases.add(r);
  }

  void deleteRelease(Release r) {
    this.releases.remove(r);
  }
}
