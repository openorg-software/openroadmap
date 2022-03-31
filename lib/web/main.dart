import 'package:flutter/material.dart';
import 'package:openroadmap/provider/appwrite_provider.dart';
import 'package:openroadmap/provider/backend_provider_interface.dart';
import 'package:openroadmap/provider/theme_provider.dart';
import 'package:openroadmap/web/views/login_view.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: ChangeNotifierProvider<BackendProviderInterface>(
          create: (context) => AppwriteProvider(),
          builder: (context, child) {
            return App();
          },
        ),
      ),
    );

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return MaterialApp(
        title: 'OpenRoadmap',
        theme: themeProvider.getTheme(),
        home: LoginView(),
        // home: DetailPage(),
      );
    });
  }
}
