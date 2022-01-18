import 'package:flutter/material.dart';
import 'package:openroadmap/model/roadmap.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:provider/provider.dart';

class EditRoadmapForm extends StatefulWidget {
  final Roadmap roadmap;

  EditRoadmapForm({this.roadmap});

  _EditRoadmapForm createState() => _EditRoadmapForm();
}

class _EditRoadmapForm extends State<EditRoadmapForm> {
  String name;
  int storyPointsPerSprint;
  int sprintLength;

  final _editKey = GlobalKey<FormState>();

  @override
  void initState() {
    name = widget.roadmap.name;
    storyPointsPerSprint = widget.roadmap.storyPointsPerSprint;
    sprintLength = widget.roadmap.sprintLength.inDays;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _editKey,
      child: Column(
        children: [
          TextFormField(
            initialValue: name,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Roadmap Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please insert Roadmap Name';
              }
              return null;
            },
            onChanged: (text) {
              this.name = text;
            },
          ),
          TextFormField(
            initialValue: '$storyPointsPerSprint',
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Story Points per sprint',
              labelText: 'Story Points per sprint:',
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  int.tryParse(value) == null) {
                return 'Please insert story point per sprint value';
              }
              return null;
            },
            onSaved: (text) {
              this.storyPointsPerSprint = int.parse(text);
            },
          ),
          TextFormField(
            initialValue: '$sprintLength',
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Sprint length in days',
              labelText: 'Sprint length in days:',
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  int.tryParse(value) == null) {
                return 'Please insert sprint length in days';
              }
              return null;
            },
            onSaved: (text) {
              this.sprintLength = int.parse(text);
            },
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Consumer<ORProvider>(
              builder: (context, orProvider, child) {
                return ElevatedButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (_editKey.currentState.validate()) {
                      _editKey.currentState.save();
                      widget.roadmap.sprintLength =
                          Duration(days: sprintLength);
                      widget.roadmap.storyPointsPerSprint =
                          storyPointsPerSprint;
                      widget.roadmap.name = name;
                      orProvider.rebuild();
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
