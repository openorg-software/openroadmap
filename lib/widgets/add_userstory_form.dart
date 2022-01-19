import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/user_story.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:provider/provider.dart';

class AddUserStoryForm extends StatefulWidget {
  final Release release;

  AddUserStoryForm({required this.release});

  _AddUserStoryForm createState() => _AddUserStoryForm();
}

class _AddUserStoryForm extends State<AddUserStoryForm> {
  late String name;
  late String description;
  late int storyPoints;

  final _editKey = GlobalKey<FormState>();

  @override
  void initState() {
    name = '';
    description = '';
    storyPoints = 0;
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
              hintText: '...',
              labelText: 'User Story name:',
            ),
            maxLength: 32,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please insert user story name';
              }
              return null;
            },
            onSaved: (text) {
              this.name = text!;
            },
          ),
          TextFormField(
            initialValue: description,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              hintText: '...',
              labelText: 'Description:',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please insert user story description';
              }
              return null;
            },
            onSaved: (text) {
              this.description = text!;
            },
          ),
          TextFormField(
            initialValue: '$storyPoints',
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              hintText: '...',
              labelText: 'Story Points:',
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  int.tryParse(value) == null) {
                return 'Please insert story point value';
              }
              return null;
            },
            onSaved: (text) {
              this.storyPoints = int.parse(text!);
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
                      UserStory wp = UserStory(
                        id: widget.release.getNextUserStoryId(),
                        releaseId: widget.release.id,
                        name: name,
                        storyPoints: storyPoints,
                        description: description,
                        discussion: [],
                        users: [],
                      );
                      widget.release.addUserStory(wp);
                      orProvider.rebuild();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added user story: $name')));
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
