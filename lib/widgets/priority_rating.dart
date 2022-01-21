import 'package:flutter/material.dart';
import 'package:openroadmap/model/user_story.dart';

class PriorityRating extends StatefulWidget {
  final UserStory userStory;

  PriorityRating({required this.userStory});

  _PriorityRating createState() => _PriorityRating();
}

class _PriorityRating extends State<PriorityRating> {
  late int priority;

  final _editKey = GlobalKey<FormState>();

  @override
  void initState() {
    priority = widget.userStory.priority;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (builder, index) {
                if (index < widget.userStory.priority) {
                  return Icon(Icons.star);
                }
                return Icon(Icons.star_border);
              })
        ],
      ),
    );
  }
}
