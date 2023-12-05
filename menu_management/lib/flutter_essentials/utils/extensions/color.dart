import "package:flutter/material.dart";

extension ColorExtensions on Color {

  // https://stackoverflow.com/a/61632770/7927429
  String get asHexTriplet {
    return '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}