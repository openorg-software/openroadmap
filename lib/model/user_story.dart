import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openroadmap/util/base64_helper.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:openroadmap/widgets/edit_userstory_form.dart';
import 'package:provider/provider.dart';

class UserStory extends StatelessWidget {
  int id;
  String name;
  int releaseId;
  String description;
  late Duration duration;
  int storyPoints;
  List<String> users;
  List<String> discussion = List<String>.empty(growable: true);

  UserStory({
    required this.id,
    required this.releaseId,
    required this.name,
    required this.storyPoints,
    required this.description,
    required this.discussion,
    required this.users,
  });

  factory UserStory.invalid() {
    return UserStory(
      id: -1,
      name: '',
      description: '',
      storyPoints: -1,
      discussion: [],
      releaseId: -1,
      users: [],
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
                                  subtitle: EditUserStoryForm(
                                    userStory: this,
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
                                            .removeUserStory(this);
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
    List userList = List.empty(growable: true);
    for (String s in this.users) {
      var encodedUser = base64Encode(utf8.encode(s));
      userList.add('"$encodedUser"');
    }
    return {
      '"id"': id,
      '"name"': '"$name"',
      '"description"': '"$description"',
      '"releaseId"': releaseId,
      '"storyPoints"': storyPoints,
      '"discussion"': discussionList,
      '"users"': userList,
    };
  }

  factory UserStory.fromJson(var json) {
    return UserStory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      releaseId: json['releaseId'],
      storyPoints: json['storyPoints'],
      discussion: Base64Helper.decodeListOfStringFromJson(json['discussion']),
      users: Base64Helper.decodeListOfStringFromJson(json['users']),
    );
  }

  static fromJsonList(var json) {
    List<UserStory> userStories = List<UserStory>.empty(growable: true);
    if (json == null) {
      return List<UserStory>.empty(growable: true);
    }
    for (var j in json) {
      if (j == null) {
        continue;
      }
      userStories.add(UserStory.fromJson(j));
    }
    return userStories;
  }
}
