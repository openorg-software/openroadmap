import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/user_story.dart';
import 'package:openroadmap/util/or_provider.dart';
import 'package:openroadmap/util/theme_provider.dart';
import 'package:openroadmap/widgets/add_release_form.dart';
import 'package:openroadmap/widgets/edit_roadmap_form.dart';
import 'package:openroadmap/widgets/export_form.dart';
import 'package:openroadmap/widgets/hover_widget.dart';
import 'package:provider/provider.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: ChangeNotifierProvider(
          create: (context) => ORProvider(),
          child: App(),
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
        home: OpenRoadmap(),
        // home: DetailPage(),
      );
    });
  }
}

class OpenRoadmap extends StatefulWidget {
  @override
  _OpenRoadmapState createState() => _OpenRoadmapState();
}

class _OpenRoadmapState extends State<OpenRoadmap> {
  @override
  void initState() {
    super.initState();
  }

  buildItemDragTarget(int releaseId, int targetUserStoryId, double height) {
    return Consumer<ORProvider>(builder: (context, orProvider, child) {
      return DragTarget<UserStory>(
        // Ensure user story is only dropped on other user story or empty list
        onWillAccept: (data) {
          return orProvider.getReleaseById(releaseId).userStories.isEmpty ||
              data!.id !=
                  orProvider
                      .getUserStoryInReleaseById(releaseId, targetUserStoryId)
                      .id;
        },
        // Move the user story on the accepted location
        onAccept: (UserStory wp) {
          setState(() {
            // Remove user story from old release
            orProvider.getReleaseById(wp.releaseId).userStories.remove(wp);
            // Insert user story in new release at target location
            // 1. Set new releaseId
            wp.releaseId = releaseId;
            // 2. Determine index for insertion
            int targetWpIndex = orProvider
                .getReleaseById(releaseId)
                .userStories
                .indexOf(orProvider.getUserStoryInReleaseById(
                    releaseId, targetUserStoryId));
            orProvider
                .getReleaseById(wp.releaseId)
                .userStories
                .insert(targetWpIndex == -1 ? 0 : targetWpIndex, wp);

            orProvider.rebuild();
          });
        },
        builder: (BuildContext context, List<UserStory?> userStories,
            List<dynamic> rejectedData) {
          if (userStories.isEmpty) {
            // The area that accepts the draggable
            return Container(
              height: height,
            );
          } else {
            return Column(
              // What's shown when hovering on it
              children: [
                Container(
                  height: height,
                ),
                ...userStories.map((item) {
                  return Opacity(
                    opacity: 0.5,
                    child: item,
                  );
                }).toList()
              ],
            );
          }
        },
      );
    });
  }

  buildHeader(Release release) {
    return Consumer<ORProvider>(
      builder: (context, orProvider, child) {
        return Stack(
          // The header
          children: [
            Draggable<Release>(
              data: release,
              child: release, // A header waiting to be dragged
              childWhenDragging: Opacity(
                // The header that's left behind
                opacity: 0.2,
                child: release,
              ),
              feedback: HoverWidget(
                child: Container(
                  // A header floating around
                  width: ThemeProvider.tileWidth,
                  child: release,
                ),
              ),
            ),
            buildItemDragTarget(release.id, 0, ThemeProvider.headerHeight),
            DragTarget<Release>(
              // Will accept others, but not himself
              onWillAccept: (incomingRelease) {
                return release.id != incomingRelease!.id;
              },
              // Moves the card into the position
              onAccept: (Release incomingRelease) {
                setState(() {
                  // Remove old release
                  orProvider.rm.releases.removeAt(orProvider.rm.releases
                      .indexOf(orProvider.getReleaseById(incomingRelease.id)));
                  // Insert at new location
                  int oldId = incomingRelease.id;
                  incomingRelease.id = release.id;
                  orProvider.getReleaseById(release.id).id = oldId;
                  if (release.id < incomingRelease.id) {
                    orProvider.rm.releases.insert(
                        orProvider.rm.releases.indexOf(release) + 1,
                        incomingRelease);
                  } else {
                    orProvider.rm.releases.insert(
                        orProvider.rm.releases.indexOf(release),
                        incomingRelease);
                  }

                  orProvider.rebuild();
                });
              },

              builder: (BuildContext context, List<Release?> releases,
                  List<dynamic> rejectedData) {
                if (releases.isEmpty) {
                  // The area that accepts the draggable
                  return Container(
                    height: ThemeProvider.headerHeight,
                    width: ThemeProvider.tileWidth,
                  );
                } else {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 3,
                      ),
                    ),
                    height: ThemeProvider.headerHeight,
                    width: ThemeProvider.tileWidth,
                  );
                }
              },
            )
          ],
        );
      },
    );
  }

  buildKanbanList(Release release, List<UserStory> items) {
    return Column(
      children: [
        buildHeader(release),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                release.userStories.length > 0
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          // A stack that provides:
                          // * A draggable object
                          // * An area for incoming draggables
                          return Stack(
                            children: [
                              Draggable<UserStory>(
                                data: items[index],
                                child: items[index],
                                // A card waiting to be dragged
                                childWhenDragging: Opacity(
                                  // The card that's left behind
                                  opacity: 0.2,
                                  child: items[index],
                                ),
                                feedback: Container(
                                  // The dragged user story
                                  height: ThemeProvider.tileHeight + 50,
                                  width: ThemeProvider.tileWidth,
                                  child: HoverWidget(
                                    child: items[index],
                                  ),
                                ),
                              ),
                              buildItemDragTarget(release.id, items[index].id,
                                  ThemeProvider.tileHeight),
                            ],
                          );
                        },
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ORProvider>(
      builder: (context, orProvider, child) {
        return Scaffold(
          appBar: AppBar(
              title: Text(
                "OpenRoadmap ${orProvider.rm != null ? '- ${orProvider.rm.name}' : ''}",
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
                              child: ListTile(
                                title: Text(
                                  'Add Release',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                trailing: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.close),
                                ),
                                subtitle: AddReleaseForm(),
                              ),
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
                orProvider.rm != null
                    ? IconButton(
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
                                        'Edit Roadmap',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      trailing: IconButton(
                                        onPressed: () => Navigator.pop(context),
                                        icon: Icon(Icons.close),
                                      ),
                                      subtitle: EditRoadmapForm(
                                        roadmap: orProvider.rm,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(
                          Icons.edit,
                        ),
                      )
                    : Container(),
                orProvider.rm != null
                    ? IconButton(
                        onPressed: () => orProvider.saveRoadmap(),
                        icon: Icon(Icons.save),
                      )
                    : Container(),
                IconButton(
                  onPressed: () => orProvider.loadRoadmap(),
                  icon: Icon(Icons.upload_file),
                ),
                orProvider.rm != null
                    ? IconButton(
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
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
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
                      )
                    : Container(),
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
          body: orProvider.rm != null
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: orProvider.rm.releases.map((Release r) {
                      return Container(
                        width: ThemeProvider.tileWidth,
                        child: buildKanbanList(r, r.userStories),
                      );
                    }).toList(),
                  ),
                )
              : Container(),
        );
      },
    );
  }
}
