import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/user_story.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:provider/provider.dart';

class AddReleaseForm extends StatefulWidget {
  AddReleaseForm();

  _AddReleaseForm createState() => _AddReleaseForm();
}

class _AddReleaseForm extends State<AddReleaseForm> {
  late String name;
  late DateTime startDate;
  late DateTime targetDate;

  final _editKey = GlobalKey<FormState>();

  @override
  void initState() {
    name = '';
    startDate = DateTime(2022, 01, 01);
    targetDate = DateTime(2022, 01, 01);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _editKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: name,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Release name',
              labelText: 'Release name:',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please insert release name';
              }
              return null;
            },
            onSaved: (text) {
              this.name = text!;
            },
          ),
          InputDatePickerFormField(
              firstDate: DateTime(2010, 1, 1),
              lastDate: DateTime(2100, 1, 1),
              initialDate: startDate,
              fieldLabelText: 'Start Date',
              onDateSaved: (date) {
                startDate = date;
              }),
          InputDatePickerFormField(
            firstDate: DateTime(2010, 1, 1),
            lastDate: DateTime(2100, 1, 1),
            initialDate: targetDate,
            fieldLabelText: 'Target Date',
            onDateSaved: (date) {
              targetDate = date;
            },
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Consumer<ORProvider>(
              builder: (context, orProvider, child) {
                return ElevatedButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (_editKey.currentState!.validate()) {
                      _editKey.currentState!.save();
                      Release r = Release(
                        id: orProvider.rm.getNextReleaseId(),
                        name: name,
                        startDate: startDate,
                        targetDate: targetDate,
                        userStories: List<UserStory>.empty(growable: true),
                        storyPointsPerSprint:
                            orProvider.rm.storyPointsPerSprint,
                        sprintLength: orProvider.rm.sprintLength,
                      );
                      orProvider.rm.addRelease(r);
                      orProvider.rebuild();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added release: $name')));
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
