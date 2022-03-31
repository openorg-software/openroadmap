import 'package:flutter/material.dart';
import 'package:openroadmap/provider/appwrite_provider.dart';
import 'package:openroadmap/web/views/main_view.dart';
import 'package:provider/provider.dart';

class RegisterView extends StatefulWidget {
  @override
  State<RegisterView> createState() => _RegisterView();
}

class _RegisterView extends State<RegisterView> {
  String password = '';
  String email = '';

  @override
  Widget build(BuildContext context) {
    final _editKey = GlobalKey<FormState>();
    return Consumer<AppwriteProvider>(
        builder: (context, appwriteProvider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: Form(
          key: _editKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: '...',
                  labelText: 'EMail:',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please insert an EMail.';
                  }
                  return null;
                },
                onSaved: (string) => email = string!,
              ),
              TextFormField(
                obscureText: true,
                obscuringCharacter: '*',
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  hintText: '...',
                  labelText: 'Password:',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please insert your password.';
                  }
                  if (value.length < 8) {
                    return 'Min. 8 characters required.';
                  }
                  return null;
                },
                onSaved: (string) => password = string!,
              ),
              ElevatedButton(
                onPressed: () {
                  if (_editKey.currentState!.validate()) {
                    _editKey.currentState!.save();
                    appwriteProvider.registerUser(email, password).then(
                          (value) => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainViewWeb(
                                email: email,
                              ),
                            ),
                          ),
                        );
                  }
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
