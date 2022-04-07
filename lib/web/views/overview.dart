import 'package:flutter/material.dart';
import 'package:openroadmap/model/roadmap.dart';
import 'package:openroadmap/provider/backend_provider_interface.dart';
import 'package:openroadmap/provider/theme_provider.dart';
import 'package:openroadmap/widgets/add_roadmap_form.dart';
import 'package:provider/provider.dart';

class Overview extends StatefulWidget {
  String email;
  Overview({
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  _Overview createState() => _Overview();
}

class _Overview extends State<Overview> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<BackendProviderInterface>(context).fetchRoadmaps();
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'OpenRoadmap - ${widget.email}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      contentPadding: EdgeInsets.all(10),
                      backgroundColor: Theme.of(context).dialogBackgroundColor,
                      children: [
                        Container(
                          width: 500,
                          child: Column(children: [
                            Row(children: [
                              Text(
                                'Add Roadmap',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.close),
                              ),
                            ]),
                            AddRoadmapForm(),
                          ]),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: Icon(
                Icons.add,
              ),
            ),
            Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
              return IconButton(
                onPressed: () => themeProvider.toggleDarkMode(),
                icon: themeProvider.darkMode
                    ? Icon(Icons.wb_sunny)
                    : Icon(Icons.dark_mode),
              );
            }),
          ]),
      body: FutureBuilder(
        future: Provider.of<BackendProviderInterface>(context).futureRoadmaps,
        builder: (BuildContext context, AsyncSnapshot<List<Roadmap>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(snapshot.data![index].name),
                    ),
                  );
                });
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary),
              ),
            );
          }
        },
      ),
    );
  }
}
