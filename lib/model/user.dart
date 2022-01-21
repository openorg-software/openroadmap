import 'package:flutter/cupertino.dart';

class User {
  String name;
  Color color;

  User({required this.name, required this.color});

  factory User.fromJson(var json) {
    return User(
      name: json['name'] != null ? json['name'] : '',
      color:
          Color(json['color'] != null ? int.parse(json['color']) : 0xff000000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '"name"': '"$name"',
      '"color"':
          '"0x${color.alpha.toRadixString(16)}${color.red.toRadixString(16)}${color.green.toRadixString(16)}${color.blue.toRadixString(16)}"'
    };
  }

  // Build a list of releases from a JSON array
  static fromJsonList(var json) {
    List<User> users = List<User>.empty(growable: true);
    if (json == null) {
      return List<User>.empty(growable: true);
    }
    for (var j in json) {
      if (j == null) {
        continue;
      }
      User r = User.fromJson(j);
      users.add(r);
    }
    return users;
  }
}
