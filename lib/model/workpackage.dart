import 'package:flutter/material.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:provider/provider.dart';

class Workpackage extends StatelessWidget {
  int id;
  String name;
  int releaseId;
  String description;
  Duration duration;
  int storyPoints;

  Workpackage(
      {this.id,
      this.releaseId,
      this.name,
      this.duration,
      this.storyPoints,
      this.description});

  factory Workpackage.invalid() {
    return Workpackage(
      id: -1,
    );
  }

  bool isValid() {
    return id != -1;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(),
        child: Consumer<ORProvider>(builder: (context, orProvider, child) {
          return ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            title: Text(
              name,
              style: TextStyle(),
            ),
            subtitle: Column(
              children: [
                Text('Story Points: $storyPoints'),
                Text(
                    'Duration in Days: ~${orProvider.getDurationFromStoryPoints(storyPoints).inDays}'),
                Row(
                  children: [
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 30.0,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              contentPadding: EdgeInsets.all(10),
                              backgroundColor:
                                  Theme.of(context).dialogBackgroundColor,
                              children: [
                                ListTile(
                                  title: Text(
                                    'Delete "$name"',
                                  ),
                                  trailing: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(Icons.close),
                                  ),
                                  subtitle: Container(
                                    padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                                    child: ElevatedButton(
                                      child: Text('Confirm'),
                                      onPressed: () {
                                        orProvider
                                            .getReleaseById(releaseId)
                                            .removeWorkpackage(this);
                                        orProvider.rebuild();
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: Icon(
                        Icons.delete,
                        size: 30.0,
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '"id"': '"$id"',
      '"name"': '"$name"',
      '"description"': '"$description"',
      '"releaseId"': '"$releaseId"',
      '"storyPoints"': storyPoints
    };
  }

  factory Workpackage.fromJson(var json) {
    return Workpackage(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      releaseId: json['releaseId'],
      storyPoints: json['storyPoints'],
    );
  }

  static fromJsonList(var json) {
    List<Workpackage> workpackages = List<Workpackage>.empty(growable: true);
    if (json == null) {
      return List<Workpackage>.empty(growable: true);
    }
    for (var j in json) {
      if (j == null) {
        continue;
      }
      workpackages.add(Workpackage.fromJson(j));
    }
    return workpackages;
  }
}
