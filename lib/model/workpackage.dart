import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:openroadmap/widgets/edit_workpackage_form.dart';
import 'package:provider/provider.dart';

class Workpackage extends StatelessWidget {
  int id;
  String name;
  int releaseId;
  String description;
  Duration duration;
  int storyPoints;
  List<String> users;
  List<String> discussion = List<String>.empty(growable: true);

  Workpackage({
    this.id,
    this.releaseId,
    this.name,
    this.duration,
    this.storyPoints,
    this.description,
    this.discussion,
  });

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
              style: TextStyle(fontWeight: FontWeight.bold),
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
                        size: 25.0,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              contentPadding: EdgeInsets.all(8),
                              backgroundColor:
                                  Theme.of(context).dialogBackgroundColor,
                              children: [
                                ListTile(
                                  title: Text(
                                    'Edit "$name"',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(Icons.close),
                                  ),
                                  subtitle: EditWorkpackageForm(
                                    workpackage: this,
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              contentPadding: EdgeInsets.all(8),
                              backgroundColor:
                                  Theme.of(context).dialogBackgroundColor,
                              children: [
                                ListTile(
                                  title: Text(
                                    'Delete "$name"',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
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
                        size: 25.0,
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
    List discussionList = List.empty(growable: true);
    for (String s in this.discussion) {
      var encodedDiscussion = base64Encode(utf8.encode(s));
      discussionList.add('"$encodedDiscussion"');
    }
    return {
      '"id"': id,
      '"name"': '"$name"',
      '"description"': '"$description"',
      '"releaseId"': releaseId,
      '"storyPoints"': storyPoints,
      '"discussion"': discussionList,
    };
  }

  factory Workpackage.fromJson(var json) {
    return Workpackage(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      releaseId: json['releaseId'],
      storyPoints: json['storyPoints'],
      discussion: decodeDiscussion(json['discussion']),
    );
  }

  static List<String> decodeDiscussion(var json) {
    List<String> discussion = List<String>.empty(growable: true);
    if (json == null) {
      return List<String>.empty(growable: true);
    }
    for (var j in json) {
      if (j == null) {
        continue;
      }
      var decodedDiscussion = base64Decode(j);
      discussion.add(utf8.decode(decodedDiscussion));
    }
    return discussion;
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
