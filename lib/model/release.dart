import 'package:flutter/material.dart';
import 'package:openroadmap/model/workpackage.dart';
import 'package:openroadmap/util/provider.dart';
import 'package:openroadmap/widgets/add_workpackage_form.dart';
import 'package:openroadmap/widgets/edit_release_form.dart';
import 'package:provider/provider.dart';

class Release extends StatelessWidget {
  String id;
  String name;
  DateTime startDate;
  DateTime endDate;
  DateTime targetDate;

  List<Workpackage> workpackages = List<Workpackage>.empty(growable: true);

  Release(
      {Key key,
      this.id,
      this.name,
      this.startDate,
      this.targetDate,
      this.workpackages})
      : super(key: key);

  factory Release.invalid() {
    return Release(
      id: '',
    );
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
                  style: TextStyle(),
                ),
                subtitle: Column(
                  children: [
                    Text(
                        'Start: ${getStartDate()} - End: ${getEndDateString(orProvider)}'),
                    Text('Story Points: ${getStoryPoints()}'),
                    Text(
                        'Duration in Days: ~${orProvider.getDurationFromStoryPoints(getStoryPoints()).inDays}'),
                    Text(
                      'Target Date: ${getTargetDate()}',
                      style: TextStyle(
                        color: targetDate.isAfter(startDate.add(orProvider
                                .getDurationFromStoryPoints(getStoryPoints())))
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    Text(
                      'Story Point Difference: ~${orProvider.getStoryPointDifference(targetDate, getEndDate(orProvider))}',
                      style: TextStyle(
                        color: targetDate.isAfter(startDate.add(orProvider
                                .getDurationFromStoryPoints(getStoryPoints())))
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                                        'Edit "$name"',
                                      ),
                                      trailing: IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: Icon(Icons.close),
                                      ),
                                      subtitle: EditReleaseForm(
                                        release: this,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.edit,
                            size: 30.0,
                          ),
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
                                    Container(
                                      width: 500,
                                      child: ListTile(
                                        title: Text(
                                          'Add Workpackage',
                                        ),
                                        trailing: IconButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          icon: Icon(Icons.close),
                                        ),
                                        subtitle: AddWorkpackageForm(
                                          release: this,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.add,
                            size: 30.0,
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

  int getStoryPoints() {
    int sum = 0;
    for (Workpackage wp in workpackages) {
      sum = sum + wp.storyPoints;
    }
    return sum;
  }

  bool isValid() {
    return id != '';
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
    return startDate
        .add(orProvider.getDurationFromStoryPoints(getStoryPoints()));
  }

  String getEndDateString(ORProvider orProvider) {
    DateTime endDate = getEndDate(orProvider);
    String day = endDate.day < 10 ? '0${endDate.day}' : '${endDate.day}';
    String month =
        endDate.month < 10 ? '0${endDate.month}' : '${endDate.month}';
    return '$day.$month.${endDate.year}';
  }

  void addWorkpackage(Workpackage wp) {
    wp.releaseId = this.id;
    wp.id = ORProvider.getUniqueWorkpackageId();
    this.workpackages.add(wp);
  }

  Map<String, dynamic> toJson() {
    List workpackages = List.empty(growable: true);
    for (Workpackage wp in this.workpackages) {
      workpackages.add(wp.toJson());
    }
    return {
      '"id"': '"$id"',
      '"name"': '"$name"',
      '"startDate"': '"$startDate"',
      '"targetDate"': '"$targetDate"',
      '"workPackages"': workpackages
    };
  }

  factory Release.fromJson(var json) {
    return Release(
      id: json['id'],
      name: json['name'],
      startDate: DateTime.parse(json['startDate']),
      targetDate: DateTime.parse(json['targetDate']),
      workpackages: Workpackage.fromJsonList(json['workPackages']),
    );
  }

  static fromJsonList(var json) {
    List<Release> releases = List<Release>.empty(growable: true);
    if (json == null) {
      return List<Release>.empty(growable: true);
    }
    for (var j in json) {
      if (j == null) {
        continue;
      }
      releases.add(Release.fromJson(j));
    }
    return releases;
  }
}
