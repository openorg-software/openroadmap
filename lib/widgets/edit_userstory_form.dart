import 'package:flutter/material.dart';
import 'package:openroadmap/model/user.dart';
import 'package:openroadmap/model/user_story.dart';
import 'package:openroadmap/provider/backend_provider_interface.dart';
import 'package:openroadmap/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class EditUserStoryForm extends StatefulWidget {
  final UserStory userStory;

  EditUserStoryForm({required this.userStory});

  _EditUserStoryForm createState() => _EditUserStoryForm();
}

class _EditUserStoryForm extends State<EditUserStoryForm> {
  late String name;
  late String description;
  late int storyPoints;
  late double priority;

  final _editKey = GlobalKey<FormState>();

  @override
  void initState() {
    name = widget.userStory.name;
    description = widget.userStory.description;
    storyPoints = widget.userStory.storyPoints;
    priority = widget.userStory.priority.toDouble();
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
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
            child: Text('Priority:'),
          ),
          Slider(
            value: priority,
            max: 5,
            divisions: 5,
            label: priority.toInt().toString(),
            onChanged: (double value) {
              setState(() {
                priority = value;
              });
            },
          ),
          Container(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
            child: Consumer<BackendProviderInterface>(
              builder: (context, orProvider, child) {
                return ElevatedButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (_editKey.currentState!.validate()) {
                      _editKey.currentState!.save();

                      widget.userStory.name = name;
                      widget.userStory.description = description;
                      widget.userStory.storyPoints = storyPoints;
                      widget.userStory.priority = priority.toInt();
                      orProvider.rebuild();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Saved user story.')));
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
                    height: orProvider.rm.users.length > 0 ? 200 : 20,
                    width: 600,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
                      child: SingleChildScrollView(
                        controller: ScrollController(),
                        child: Wrap(
                          children: orProvider.rm.users.map((User u) {
                            return Container(
                              padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                              child: ActionChip(
                                avatar: widget.userStory
                                        .containsUserWithId(u.id)
                                    ? Icon(
                                        Icons.remove,
                                        color: u.color.computeLuminance() >
                                                ThemeProvider.brigthToDarkBorder
                                            ? Colors.black
                                            : Colors.white,
                                      )
                                    : Icon(
                                        Icons.add,
                                        color: u.color.computeLuminance() >
                                                ThemeProvider.brigthToDarkBorder
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                label: Text(u.name,
                                    style: TextStyle(
                                      color: u.color.computeLuminance() >
                                              ThemeProvider.brigthToDarkBorder
                                          ? Colors.black
                                          : Colors.white,
                                    )),
                                backgroundColor: u.color,
                                onPressed: () {
                                  if (widget.userStory
                                      .containsUserWithId(u.id)) {
                                    widget.userStory.users.remove(widget
                                        .userStory.users
                                        .firstWhere((User u) => u.id == u.id));
                                  } else {
                                    widget.userStory.users.add(u);
                                  }
                                  orProvider.rebuild();
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Divider(),
          Column(
            children: [
              Text(
                'Discussion',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Consumer<BackendProviderInterface>(
                  builder: (context, orProvider, child) {
                return Container(
                  padding: EdgeInsets.fromLTRB(0, 8, 0, 16),
                  child: ElevatedButton(
                    child: Text('Add discussion'),
                    onPressed: () {
                      widget.userStory.discussion.add('');
                      orProvider.rebuild();
                    },
                  ),
                );
              }),
              Container(
                height: 200,
                width: 600,
                child: Consumer<BackendProviderInterface>(
                  builder: (context, orProvider, child) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      controller: ScrollController(),
                      shrinkWrap: true,
                      itemCount: widget.userStory.discussion.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Row(
                          children: [
                            Container(
                              width: 550,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: UnderlineInputBorder(),
                                  hintText: 'New discussion...',
                                ),
                                initialValue:
                                    widget.userStory.discussion[index],
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                onChanged: (value) {
                                  widget.userStory.discussion[index] = value;
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                String discussion =
                                    widget.userStory.discussion[index];
                                widget.userStory.discussion.remove(discussion);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Removed discussion.'),
                                    action: SnackBarAction(
                                      label: 'Revert',
                                      onPressed: () {
                                        widget.userStory.discussion
                                            .add(discussion);
                                      },
                                    ),
                                  ),
                                );

                                orProvider.rebuild();
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
          )
        ],
      ),
    );
  }
}
