import "package:flutter/material.dart";

/// Extensions on [Color] for common color operations.
extension ColorExtensions on Color {
  /// Returns the color as a hex triplet string (e.g., "#FF5733").
  String get asHexTriplet {
    return "#${(toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, "0").toUpperCase()}";
  }

  /// Maps an input string deterministically to a color from the provided [colorList].
  ///
  /// Uses the hash code of the input to ensure the same string always maps to
  /// the same color. Useful for assigning consistent colors to categories, users, etc.
  static Color mapStringToColor(String input, List<Color> colorList) {
    int hash = input.hashCode;
    int index = hash.abs() % colorList.length;
    return colorList[index];
  }

  /// Creates a semi-transparent blur overlay color based on the given [brightness].
  ///
  /// Useful for glass-morphism or frosted-glass effects.
  static Color blurColor(double brightness) {
    return Color.alphaBlend(Colors.black.withValues(alpha: brightness), Colors.white).withValues(alpha: 0.15);
  }
}
