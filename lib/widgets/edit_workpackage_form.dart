import 'package:flutter/material.dart';
import 'package:openroadmap/model/workpackage.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:provider/provider.dart';

class EditWorkpackageForm extends StatefulWidget {
  final Workpackage workpackage;

  EditWorkpackageForm({this.workpackage});

  _EditWorkpackageForm createState() => _EditWorkpackageForm();
}

class _EditWorkpackageForm extends State<EditWorkpackageForm> {
  String name;
  String description;
  int storyPoints;

  final _editKey = GlobalKey<FormState>();

  @override
  void initState() {
    name = widget.workpackage.name;
    description = widget.workpackage.description;
    storyPoints = widget.workpackage.storyPoints;
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

                      widget.workpackage.name = name;
                      widget.workpackage.description = description;
                      widget.workpackage.storyPoints = storyPoints;
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
