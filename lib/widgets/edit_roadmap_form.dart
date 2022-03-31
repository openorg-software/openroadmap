import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:openroadmap/model/roadmap.dart';
import 'package:openroadmap/model/user.dart';
import 'package:openroadmap/provider/backend_provider_interface.dart';
import 'package:openroadmap/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class EditRoadmapForm extends StatefulWidget {
  final Roadmap roadmap;

  EditRoadmapForm({required this.roadmap});

  _EditRoadmapForm createState() => _EditRoadmapForm();
}

class _EditRoadmapForm extends State<EditRoadmapForm> {
  late String name;
  late int storyPointsPerSprint;
  late int sprintLength;
  late String style;
  final _editKey = GlobalKey<FormState>();

  @override
  void initState() {
    name = widget.roadmap.name;
    storyPointsPerSprint = widget.roadmap.storyPointsPerSprint;
    sprintLength = widget.roadmap.sprintLength.inDays;
    style = widget.roadmap.userDefinedStyle;
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
              this.storyPointsPerSprint = int.parse(text!);
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
              this.sprintLength = int.parse(text!);
            },
          ),
          Divider(),
          TextFormField(
            initialValue: style,
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              hintText: '...',
              labelText: 'PlantUML Gantt Chart Style:',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please insert style';
              }
              return null;
            },
            onSaved: (text) {
              this.style = text!;
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
                      widget.roadmap.sprintLength =
                          Duration(days: sprintLength);
                      widget.roadmap.storyPointsPerSprint =
                          storyPointsPerSprint;
                      widget.roadmap.name = name;
                      widget.roadmap.userDefinedStyle = style;
                      orProvider.rebuild();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Saved roadmap.')));
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
          Divider(),
          Column(
            children: [
              Text(
                'Users',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Consumer<BackendProviderInterface>(
                  builder: (context, orProvider, child) {
                return Container(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
                  child: ElevatedButton(
                    child: Text('Add user'),
                    onPressed: () {
                      orProvider.rm.addUser();
                      orProvider.rebuild();
                    },
                  ),
                );
              }),
              Container(
                height: 200,
                width: 350,
                child: Consumer<BackendProviderInterface>(
                  builder: (context, orProvider, child) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: widget.roadmap.users.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          children: [
                            Container(
                              width: 250,
                              child: TextFormField(
                                initialValue: widget.roadmap.users[index].name,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                onChanged: (value) {
                                  widget.roadmap.users[index].name = value;
                                  orProvider.rebuild();
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Color pickerColor =
                                    widget.roadmap.users[index].color;
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                      children: [
                                        ListTile(
                                          title: Text(
                                            'Select Color',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          trailing: IconButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            icon: Icon(Icons.close),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              8, 0, 8, 0),
                                          child: ColorPicker(
                                              pickerColor: pickerColor,
                                              onColorChanged: (color) {
                                                widget.roadmap.users[index]
                                                    .color = color;
                                                orProvider.rebuild();
                                              }),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.color_lens,
                                color: widget.roadmap.users[index].color,
                              ),
                              color: widget.roadmap.users[index].color
                                          .computeLuminance() <
                                      ThemeProvider.brigthToDarkBorder
                                  ? Colors.grey
                                  : Colors.white,
                            ),
                            IconButton(
                              onPressed: () {
                                User user = widget.roadmap.users[index];
                                if (widget.roadmap.removeUser(user, context)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Removed user: $user'),
                                      action: SnackBarAction(
                                        label: 'Revert',
                                        onPressed: () {
                                          widget.roadmap.users.add(
                                            user,
                                          );
                                          orProvider.rebuild();
                                        },
                                      ),
                                    ),
                                  );
                                  orProvider.rebuild();
                                }
                              },
                              icon: Icon(Icons.delete),
                            )
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
    );
  }
}
