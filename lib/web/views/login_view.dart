import 'package:flutter/material.dart';
import 'package:openroadmap/provider/backend_provider_interface.dart';
import 'package:openroadmap/web/views/overview.dart';
import 'package:openroadmap/web/views/register_view.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  @override
  State<LoginView> createState() => _LoginView();
}

class _LoginView extends State<LoginView> {
  final _editKey = GlobalKey<FormState>();

  String password = '';
  String email = '';
  @override
  Widget build(BuildContext context) {
    return Consumer<BackendProviderInterface>(
        builder: (context, appwriteProvider, child) {
      return Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Form(
          key: _editKey,
          child: Container(
            margin: EdgeInsets.fromLTRB(50, 0, 50, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Container(
                  margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
                  height: 64,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_editKey.currentState!.validate()) {
                        _editKey.currentState!.save();
                        appwriteProvider.login(email, password).then(
                              (value) => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Overview(
                                    email: email,
                                  ),
                                ),
                              ),
                            );
                      }
                    },
                    child: Text('Login'),
                  ),
                ),
                Divider(),
                Container(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisterView())),
                    child: Text('Register'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
