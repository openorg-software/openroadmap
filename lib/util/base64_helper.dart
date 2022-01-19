import 'dart:convert';

class Base64Helper {
  static List<String> decodeListOfStringFromJson(var json) {
    List<String> strings = List<String>.empty(growable: true);
    if (json == null) {
      return List<String>.empty(growable: true);
    }
    for (var j in json) {
      if (j == null) {
        continue;
      }
      strings.add(decodeString(j));
    }
    return strings;
  }

  static String encodeString(String s) {
    if (s == '' || s == null) {
      return '';
    }
    return base64Encode(utf8.encode(s));
  }

  static String decodeString(String s) {
    if (s == '' || s == null) {
      return '';
    }
    return utf8.decode(base64Decode(s));
  }
}
