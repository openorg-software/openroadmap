import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/roadmap.dart';
import 'package:openroadmap/provider/backend_provider_interface.dart';
import 'package:openroadmap/provider/theme_provider.dart';
import 'package:openroadmap/widgets/add_release_form.dart';
import 'package:openroadmap/widgets/edit_roadmap_form.dart';
import 'package:openroadmap/widgets/export_form.dart';
import 'package:openroadmap/widgets/kanban_list.dart';
import 'package:provider/provider.dart';

class MainViewWeb extends StatefulWidget {
  String email;
  MainViewWeb({
    required this.email,
    Key? key,
  }) : super(key: key);

  @override
  _MainViewWeb createState() => _MainViewWeb();
}

class _MainViewWeb extends State<MainViewWeb> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BackendProviderInterface>(
      builder: (context, backendProvider, child) {
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
                          backgroundColor:
                              Theme.of(context).dialogBackgroundColor,
                          children: [
                            Container(
                              width: 500,
                              child: Column(children: [
                                Row(children: [
                                  Text(
                                    'Add Release',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.pop(context),
                                    icon: Icon(Icons.close),
                                  ),
                                ]),
                                AddReleaseForm(),
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
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return buildEditRoadmapDialog(context, backendProvider);
                      },
                    );
                  },
                  icon: Icon(
                    Icons.edit,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          contentPadding: EdgeInsets.all(10),
                          backgroundColor:
                              Theme.of(context).dialogBackgroundColor,
                          children: [
                            Container(
                              width: 500,
                              child: ListTile(
                                title: Text(
                                  'Export Roadmap',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                trailing: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.close),
                                ),
                                subtitle: ExportForm(),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.share),
                ),
                Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                  return IconButton(
                    onPressed: () => themeProvider.toggleDarkMode(),
                    icon: themeProvider.darkMode
                        ? Icon(Icons.wb_sunny)
                        : Icon(Icons.dark_mode),
                  );
                }),
              ]),
          body: FutureBuilder(
            future: backendProvider.frm,
            builder: (BuildContext context, AsyncSnapshot<Roadmap> snapshot) {
              if (snapshot.hasData) {
                backendProvider.rm = snapshot.data!;
                if (backendProvider.rm.releases.length == 0) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              contentPadding: EdgeInsets.all(10),
                              backgroundColor:
                                  Theme.of(context).dialogBackgroundColor,
                              children: [
                                Container(
                                  width: 500,
                                  child: Column(children: [
                                    Row(children: [
                                      Text(
                                        'Add Release',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: Icon(Icons.close),
                                      ),
                                    ]),
                                    AddReleaseForm(),
                                  ]),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text('Add first release'),
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: ScrollController(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: backendProvider.rm.releases.map((Release r) {
                        return Container(
                          width: ThemeProvider.tileWidth,
                          child: KanbanList(
                            email: widget.email,
                            release: r,
                            items: r.userStories,
                            darkBackground:
                                backendProvider.rm.releases.indexOf(r) % 2 == 0,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(
                        Theme.of(context).accentColor),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  SimpleDialog buildEditRoadmapDialog(
      BuildContext context, BackendProviderInterface orProvider) {
    return SimpleDialog(
      contentPadding: EdgeInsets.all(10),
      backgroundColor: Theme.of(context).dialogBackgroundColor,
      children: [
        Container(
          width: 500,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Edit Roadmap',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              EditRoadmapForm(
                roadmap: orProvider.rm,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
