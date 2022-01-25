import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:openroadmap/model/user.dart';
import 'package:openroadmap/util/base64_helper.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:openroadmap/widgets/edit_userstory_form.dart';
import 'package:openroadmap/widgets/priority_rating.dart';
import 'package:provider/provider.dart';

class UserStory extends StatelessWidget {
  int id;
  String name;
  int releaseId;
  String description;
  late Duration duration;
  int storyPoints;
  List<User> users;
  List<String> discussion = List<String>.empty(growable: true);
  int priority;

  UserStory({
    required this.id,
    required this.releaseId,
    required this.name,
    required this.storyPoints,
    required this.description,
    required this.discussion,
    required this.users,
    required this.priority,
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
      priority: 0,
    );
  }

  bool isValid() {
    return id != -1;
  }

  Map<String, dynamic> toJson() {
    List discussionList = List.empty(growable: true);
    for (String s in this.discussion) {
      var encodedDiscussion = base64Encode(utf8.encode(s));
      discussionList.add('"$encodedDiscussion"');
    }
    List userList = List.empty(growable: true);
    for (User s in this.users) {
      userList.add(s.toJson());
    }
    return {
      '"id"': id,
      '"name"': '"$name"',
      '"description"': '"${Base64Helper.encodeString(description)}"',
      '"releaseId"': releaseId,
      '"storyPoints"': storyPoints,
      '"discussion"': discussionList,
      '"users"': userList,
      '"priority"': priority,
    };
  }

  factory UserStory.fromJson(var json, int roadmapSpecVersion) {
    String description = '';
    if (roadmapSpecVersion > 0) {
      description = Base64Helper.decodeString(json['description']);
    } else {
      description = json['description'];
    }
    return UserStory(
      id: json['id'],
      name: json['name'],
      description: description,
      releaseId: json['releaseId'],
      storyPoints: json['storyPoints'],
      discussion: Base64Helper.decodeListOfStringFromJson(json['discussion']),
      users: User.fromJsonList(json['users']) != null
          ? User.fromJsonList(json['users'])
          : [],
      priority: json['priority'] != null ? json['priority'] : 0,
    );
  }

  static fromJsonList(var json, int roadmapSpecVersion) {
    List<UserStory> userStories = List<UserStory>.empty(growable: true);
    if (json == null) {
      return List<UserStory>.empty(growable: true);
    }
    for (var j in json) {
      if (j == null) {
        continue;
      }
      userStories.add(UserStory.fromJson(j, roadmapSpecVersion));
    }
    return userStories;
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Story Points: $storyPoints'),
                Text(
                    'Duration in Days: ~${orProvider.getDurationFromStoryPoints(storyPoints).inDays}'),
                priority > 0 ? PriorityRating(userStory: this) : Container(),
                users.length > 0 ? Divider() : Container(),
                users.length > 0 ? Text('Users:') : Container(),
                users.length > 0
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                        child: GridView.builder(
                          itemCount: users.length,
                          shrinkWrap: true,
                          gridDelegate:
                              new SliverGridDelegateWithMaxCrossAxisExtent(
                                  //crossAxisCount: 4,
                                  maxCrossAxisExtent: 80,
                                  mainAxisSpacing: 0,
                                  childAspectRatio: 2.5),
                          itemBuilder: (BuildContext context, int index) {
                            return Center(
                              child: Chip(
                                label: Text(users[index].name),
                                labelPadding: EdgeInsets.fromLTRB(4, 0, 4, 0),
                                backgroundColor: orProvider.rm.users
                                    .firstWhere(
                                        (User u) => u.id == users[index].id)
                                    .color,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(),
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
                            return getEditDialog(context, orProvider);
                          },
                        );
                      },
                    ),
                    IconButton(
                      onPressed: () {
                        orProvider.rm.releases
                            .firstWhere((element) => element.id == releaseId)
                            .addUserStory(
                              UserStory(
                                id: orProvider.rm.releases
                                    .firstWhere(
                                        (element) => element.id == releaseId)
                                    .getNextUserStoryId(),
                                releaseId: releaseId,
                                name: name,
                                storyPoints: storyPoints,
                                description: description,
                                discussion: discussion.toList(),
                                users: users.toList(),
                                priority: priority,
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Copied userstory "$name"')));
                        orProvider.rebuild();
                      },
                      icon: Icon(
                        Icons.copy,
                        size: 25.0,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return getDeleteDialog(context, orProvider);
                            });
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

  SimpleDialog getEditDialog(BuildContext context, ORProvider orProvider) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(16),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      children: [
        Container(
          width: 600,
          height: 1,
        ),
        Row(
          children: [
            Text(
              'Edit "$name"',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Spacer(),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close),
            ),
          ],
        ),
        EditUserStoryForm(
          userStory: this,
        ),
      ],
    );
  }

  SimpleDialog getDeleteDialog(BuildContext context, ORProvider orProvider) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(8),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      children: [
        ListTile(
          title: Text(
            'Delete "$name"',
            style: TextStyle(fontWeight: FontWeight.bold),
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
                orProvider.getReleaseById(releaseId).removeUserStory(this);
                orProvider.rebuild();
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}
