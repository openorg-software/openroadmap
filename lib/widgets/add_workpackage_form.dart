import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/workpackage.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:provider/provider.dart';

class AddWorkpackageForm extends StatefulWidget {
  final Release release;

  AddWorkpackageForm({this.release});

  _AddWorkpackageForm createState() => _AddWorkpackageForm();
}

class _AddWorkpackageForm extends State<AddWorkpackageForm> {
  String name;
  String description;
  int storyPoints;

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
              labelText: 'Workpackage name:',
            ),
            maxLength: 32,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please insert workpackage name';
              }
              return null;
            },
            onSaved: (text) {
              this.name = text;
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
                return 'Please insert workpackage description';
              }
              return null;
            },
            onSaved: (text) {
              this.description = text;
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
              this.storyPoints = int.parse(text);
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
                      Workpackage wp = Workpackage(
                        name: name,
                        storyPoints: storyPoints,
                        description: description,
                        discussion: List<String>.empty(growable: true),
                      );
                      widget.release.addWorkpackage(wp);
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
