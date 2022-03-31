import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/provider/backend_provider_interface.dart';
import 'package:provider/provider.dart';

class EditReleaseForm extends StatefulWidget {
  final Release release;

  EditReleaseForm({required this.release});

  _EditReleaseForm createState() => _EditReleaseForm();
}

class _EditReleaseForm extends State<EditReleaseForm> {
  late String name;
  late DateTime startDate;
  late DateTime targetDate;

  final _editKey = GlobalKey<FormState>();

  @override
  void initState() {
    name = widget.release.name;
    startDate = widget.release.startDate;
    targetDate = widget.release.targetDate;
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
              hintText: 'Release Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please insert Release Name';
              }
              return null;
            },
            onChanged: (text) {
              this.name = text;
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
          TextFormField(
            initialValue: '${this.widget.release.storyPointsPerSprint}',
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
              this.widget.release.storyPointsPerSprint = int.parse(text!);
            },
          ),
          TextFormField(
            initialValue: '${this.widget.release.sprintLength.inDays}',
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
              this.widget.release.sprintLength =
                  Duration(days: int.parse(text!));
            },
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Consumer<BackendProviderInterface>(
              builder: (context, orProvider, child) {
                return ElevatedButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (_editKey.currentState!.validate()) {
                      _editKey.currentState!.save();
                      widget.release.startDate = startDate;
                      widget.release.targetDate = targetDate;
                      widget.release.name = name;
                      orProvider.rebuild();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Saved release: $name')));
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
