import 'package:flutter/material.dart';
import 'package:openroadmap/model/roadmap.dart';
import 'package:openroadmap/provider/backend_provider_interface.dart';
import 'package:provider/provider.dart';

class AddRoadmapForm extends StatefulWidget {
  AddRoadmapForm();

  _AddRoadmapForm createState() => _AddRoadmapForm();
}

class _AddRoadmapForm extends State<AddRoadmapForm> {
  late String name;

  final _editKey = GlobalKey<FormState>();

  @override
  void initState() {
    name = '';
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
            maxLength: 32,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              hintText: 'Roadmap name',
              labelText: 'Roadmap name:',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please insert roadmap name';
              }
              return null;
            },
            onSaved: (text) {
              this.name = text!;
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
                      Roadmap r = Roadmap.empty(name);
                      orProvider.addRoadmap(r);
                      orProvider.rebuild();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added roadmap: $name')));
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
