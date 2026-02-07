import "package:flutter/material.dart";

extension TimeOfDayExtensions on TimeOfDay {
  bool isAfter([TimeOfDay? other]) {
    other ??= TimeOfDay.now();
    return hour > other.hour || (hour == other.hour && minute > other.minute);
  }

  bool isBefore([TimeOfDay? other]) {
    other ??= TimeOfDay.now();
    return hour < other.hour || (hour == other.hour && minute < other.minute);
  }

  String get asFormattedString {
    return "${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}";
  }

  String get asJson {
    return asFormattedString;
  }

  // Trick around static extensions: https://stackoverflow.com/a/59731018
  // You can declare static methods in an extension, but they are static on the extension itself (you call them using ExtensionName.methodName()).
  // Stop once this is completed WaitingForUpdate on https://github.com/dart-lang/language/issues/723
  static TimeOfDay parse(String str) {
    List<String> parts = str.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  static String itemToJson(TimeOfDay obj) {
    return obj.asFormattedString;
  }

  static TimeOfDay jsonToItem(String obj) {
    return parse(obj);
  }

  DateTime asDateTime({DateTime? date}) {
    date ??= DateTime.fromMicrosecondsSinceEpoch(0);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}
