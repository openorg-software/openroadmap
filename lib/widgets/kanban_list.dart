import 'package:flutter/material.dart';
import 'package:openroadmap/model/release.dart';
import 'package:openroadmap/model/user_story.dart';
import 'package:openroadmap/provider/backend_provider_interface.dart';
import 'package:openroadmap/provider/theme_provider.dart';
import 'package:openroadmap/widgets/hover_widget.dart';
import 'package:provider/provider.dart';

class KanbanList extends StatefulWidget {
  Release release;
  List<UserStory> items;
  bool darkBackground;

  String email;
  KanbanList({
    required this.email,
    required this.release,
    required this.items,
    required this.darkBackground,
    Key? key,
  }) : super(key: key);

  @override
  _KanbanList createState() => _KanbanList();
}

class _KanbanList extends State<KanbanList> {
  buildItemDragTarget(int releaseId, int targetUserStoryId, double height) {
    return Consumer<BackendProviderInterface>(
        builder: (context, orProvider, child) {
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
    return Consumer<BackendProviderInterface>(
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
                  // Set release id for new release and all of its user stories
                  incomingRelease.id = release.id;
                  incomingRelease.userStories.forEach((UserStory u) {
                    u.releaseId = release.id;
                  });
                  // Set release id for old release and all of its user stories
                  orProvider.getReleaseById(release.id).id = oldId;
                  orProvider
                      .getReleaseById(release.id)
                      .userStories
                      .forEach((UserStory u) {
                    u.releaseId = oldId;
                  });
                  // Insert release at correct location
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.darkBackground
          ? Color.fromARGB(10, 0, 0, 0)
          : Color.fromARGB(10, 255, 255, 255),
      child: Column(
        children: [
          buildHeader(widget.release),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: ScrollController(),
              child: Column(
                children: [
                  widget.release.userStories.length > 0
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: widget.items.length,
                          controller: ScrollController(),
                          itemBuilder: (BuildContext context, int index) {
                            // A stack that provides:
                            // * A draggable object
                            // * An area for incoming draggables
                            return Stack(
                              children: [
                                Draggable<UserStory>(
                                  data: widget.items[index],
                                  child: widget.items[index],
                                  // A card waiting to be dragged
                                  childWhenDragging: Opacity(
                                    // The card that's left behind
                                    opacity: 0.2,
                                    child: widget.items[index],
                                  ),
                                  feedback: Container(
                                    // The dragged user story
                                    height: 50,
                                    width: ThemeProvider.tileWidth,
                                    child: HoverWidget(
                                      child: Card(
                                        child: ListTile(
                                          title: Text(
                                            widget.items[index].name,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                buildItemDragTarget(
                                    widget.release.id,
                                    widget.items[index].id,
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
      ),
    );
  }
}
