import 'package:flutter/material.dart';

class HoverWidget extends StatelessWidget {
  final Widget child;

  HoverWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.05,
      child: child,
    );
  }
}
