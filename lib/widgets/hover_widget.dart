import 'package:flutter/material.dart';

class HoverWidget extends StatelessWidget {
  final Widget child;

  HoverWidget({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.05,
      child: child,
    );
  }
}
