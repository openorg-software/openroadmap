import 'package:flutter/material.dart';

class User {
  int id;
  String name;
  Color color;

  User({required this.id, required this.name, required this.color});

  factory User.fromJson(var json, List<User> users) {
    return User(
      id: json['id'] != null ? json['id'] : determineHighestUserId(users),
      name: json['name'] != null ? json['name'] : '',
      color:
          Color(json['color'] != null ? int.parse(json['color']) : 0xff000000),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '"id"': id,
      '"name"': '"$name"',
      '"color"': '"0x${color.alpha.toRadixString(16).length == 1 ? '0${color.alpha.toRadixString(16)}' : color.alpha.toRadixString(16)}' +
          '${color.red.toRadixString(16).length == 1 ? '0${color.red.toRadixString(16)}' : color.red.toRadixString(16)}' +
          '${color.green.toRadixString(16).length == 1 ? '0${color.green.toRadixString(16)}' : color.green.toRadixString(16)}' +
          '${color.blue.toRadixString(16).length == 1 ? '0${color.blue.toRadixString(16)}' : color.blue.toRadixString(16)}"'
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
      User r = User.fromJson(j, users);
      users.add(r);
    }
    return users;
  }

  // Figure out the highest user id
  static int determineHighestUserId(List<User> users) {
    int highestUserId = 0;
    for (User u in users) {
      if (u.id > highestUserId) {
        highestUserId = u.id;
      }
    }
    highestUserId++;
    return highestUserId;
  }
}
