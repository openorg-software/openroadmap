import 'package:flutter/material.dart';
import 'package:openroadmap/model/user_story.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:openroadmap/util/storypoint_calculator.dart';
import 'package:openroadmap/widgets/add_userstory_form.dart';
import 'package:openroadmap/widgets/edit_release_form.dart';
import 'package:provider/provider.dart';

class Release extends StatelessWidget {
  int id;
  String name;
  DateTime startDate;
  late DateTime endDate;
  DateTime targetDate;
  int highestUsId = 0;
  int storyPointsPerSprint;
  Duration sprintLength;

  List<UserStory> userStories = List<UserStory>.empty(growable: true);

  Release({
    required this.id,
    required this.name,
    required this.startDate,
    required this.targetDate,
    required this.userStories,
    required this.storyPointsPerSprint,
    required this.sprintLength,
  });

  Map<String, dynamic> toJson() {
    List userStories = List.empty(growable: true);
    for (UserStory wp in this.userStories) {
      userStories.add(wp.toJson());
    }
    return {
      '"id"': id,
      '"name"': '"$name"',
      '"startDate"': '"$startDate"',
      '"targetDate"': '"$targetDate"',
      '"userStories"': userStories,
      '"storyPointsPerSprint"': storyPointsPerSprint,
      '"sprintLength"': sprintLength.inDays,
    };
  }

  factory Release.fromJson(var json, int roadmapSpecVersion,
      int storyPointsPerSprint, int sprintLength) {
    int newStoryPointsPerSprint = 10;
    int newSprintLength = 14;
    if (roadmapSpecVersion < 2) {
      newStoryPointsPerSprint = storyPointsPerSprint;
      newSprintLength = sprintLength;
    } else {
      newStoryPointsPerSprint = json['storyPointsPerSprint'];
      newSprintLength = json['sprintLength'];
    }
    return Release(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      targetDate: DateTime.parse(json['targetDate']),
      userStories:
          UserStory.fromJsonList(json['userStories'], roadmapSpecVersion),
      storyPointsPerSprint: newStoryPointsPerSprint,
      sprintLength: Duration(days: newSprintLength),
    );
  }

  // Build a list of releases from a JSON array
  static fromJsonList(var json, int roadmapSpecVersion,
      int storyPointsPerSprint, int sprintLength) {
    List<Release> releases = List<Release>.empty(growable: true);
    if (json == null) {
      return List<Release>.empty(growable: true);
    }
    for (var j in json) {
      if (j == null) {
        continue;
      }
      Release r = Release.fromJson(
          j, roadmapSpecVersion, storyPointsPerSprint, sprintLength);
      r.determineHighestUSId();
      releases.add(r);
    }
    return releases;
  }

  factory Release.invalid() {
    return Release(
      id: -1,
      name: '',
      targetDate: DateTime(2022),
      startDate: DateTime(2022),
      userStories: [],
      sprintLength: Duration(days: 0),
      storyPointsPerSprint: 0,
    );
  }

  bool isValid() {
    return id != -1;
  }

  int getStoryPoints() {
    int sum = 0;
    for (UserStory wp in userStories) {
      sum = sum + wp.storyPoints;
    }
    return sum;
  }

  String getStartDate() {
    String day = startDate.day < 10 ? '0${startDate.day}' : '${startDate.day}';
    String month =
        startDate.month < 10 ? '0${startDate.month}' : '${startDate.month}';
    return '$day.$month.${startDate.year}';
  }

  String getTargetDate() {
    String day =
        targetDate.day < 10 ? '0${targetDate.day}' : '${targetDate.day}';
    String month =
        targetDate.month < 10 ? '0${targetDate.month}' : '${targetDate.month}';
    return '$day.$month.${targetDate.year}';
  }

  DateTime getEndDate(ORProvider orProvider) {
    return startDate.add(StoryPointCalculator.getDurationFromStoryPoints(
        getStoryPoints(), sprintLength.inDays, storyPointsPerSprint));
  }

  // Get the end date as string
  String getEndDateString(ORProvider orProvider) {
    DateTime endDate = getEndDate(orProvider);
    String day = endDate.day < 10 ? '0${endDate.day}' : '${endDate.day}';
    String month =
        endDate.month < 10 ? '0${endDate.month}' : '${endDate.month}';
    return '$day.$month.${endDate.year}';
  }

  int getNextUserStoryId() {
    this.highestUsId++;
    return this.id * 10000 + (highestUsId - this.id * 10000);
  }

  // Add given user story
  void addUserStory(UserStory us) {
    this.userStories.add(us);
  }

  // Remove given user story
  void removeUserStory(UserStory us) {
    this.userStories.remove(us);
  }

  // Figure out the highest user story id
  void determineHighestUSId() {
    int highestUsId = 0;
    for (UserStory wp in userStories) {
      if (wp.id > highestUsId) {
        highestUsId = wp.id;
      }
    }
    this.highestUsId = highestUsId;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ORProvider>(
      builder: (context, orProvider, child) {
        return Column(
          children: [
            Card(
              elevation: 5,
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                title: Text(
                  '$name',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
                ),
                subtitle: Column(
                  children: [
                    Text(
                        'Start: ${getStartDate()} - End: ${getEndDateString(orProvider)}'),
                    Text('Story Points: ${getStoryPoints()}'),
                    Text(
                        'Duration in Days: ~${StoryPointCalculator.getDurationFromStoryPoints(getStoryPoints(), sprintLength.inDays, storyPointsPerSprint).inDays}'),
                    Text(
                      'Target Date: ${getTargetDate()}',
                      style: TextStyle(
                        color: targetDate.isAfter(startDate.add(
                                StoryPointCalculator.getDurationFromStoryPoints(
                                    getStoryPoints(),
                                    sprintLength.inDays,
                                    storyPointsPerSprint)))
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    Text(
                      'Story Point Difference: ~${StoryPointCalculator.getStoryPointDifference(targetDate, getEndDate(orProvider), sprintLength.inDays, storyPointsPerSprint)}',
                      style: TextStyle(
                        color: targetDate.isAfter(startDate.add(
                                StoryPointCalculator.getDurationFromStoryPoints(
                                    getStoryPoints(),
                                    sprintLength.inDays,
                                    storyPointsPerSprint)))
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Tooltip(
                          message: 'Add User Story',
                          child: InkWell(
                            child: Icon(
                              Icons.add,
                              size: 30.0,
                            ),
                            radius: 64,
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleDialog(
                                    contentPadding: EdgeInsets.all(10),
                                    backgroundColor:
                                        Theme.of(context).dialogBackgroundColor,
                                    children: [
                                      Container(
                                        width: 500,
                                        child: Column(
                                          children: [
                                            Row(children: [
                                              Text(
                                                'Add User Story',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                icon: Icon(Icons.close),
                                              ),
                                            ]),
                                            AddUserStoryForm(
                                              release: this,
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Spacer(),
                        Tooltip(
                          message: 'Edit Release',
                          child: InkWell(
                            child: Container(
                              margin: EdgeInsets.all(4),
                              child: Icon(
                                Icons.edit,
                                size: 30.0,
                              ),
                            ),
                            radius: 64,
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleDialog(
                                    contentPadding: EdgeInsets.all(10),
                                    backgroundColor:
                                        Theme.of(context).dialogBackgroundColor,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Edit "$name"',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            icon: Icon(Icons.close),
                                          ),
                                        ],
                                      ),
                                      EditReleaseForm(
                                        release: this,
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        Tooltip(
                          message: 'Delete Release',
                          child: InkWell(
                            child: Container(
                              margin: EdgeInsets.all(4),
                              child: Icon(
                                Icons.delete,
                                size: 30.0,
                              ),
                            ),
                            radius: 64,
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleDialog(
                                    contentPadding: EdgeInsets.all(10),
                                    backgroundColor:
                                        Theme.of(context).dialogBackgroundColor,
                                    children: [
                                      Row(children: [
                                        Text(
                                          'Delete "$name"',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          icon: Icon(Icons.close),
                                        ),
                                      ]),
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 16, 0, 0),
                                        child: ElevatedButton(
                                          child: Text('Confirm'),
                                          onPressed: () {
                                            orProvider.rm
                                                .deleteRelease(this, context);
                                            orProvider.rebuild();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
