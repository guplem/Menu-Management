import "package:flutter/material.dart";
import "package:menu_management/theme/theme_custom.dart";

class DynamicTheme extends ChangeNotifier {
  static final DynamicTheme instance = DynamicTheme(); // Singleton pattern

  ThemeData lastTheme = ThemeCustom.defaultTheme;

  Color lastColor = ThemeCustom.defaultSeedColor;
  int lastMaterialVersion = ThemeCustom.defaultMaterialVersion;
  ThemeMode lastThemeMode = ThemeCustom.defaultThemeMode;

  void updateTheme({Color? color, int? materialVersion = 3, ThemeMode? themeMode}) {
    Color newColor = color ?? lastColor;
    int newMaterialVersion = materialVersion ?? lastMaterialVersion;
    ThemeMode newThemeMode = themeMode ?? lastThemeMode;

    if (lastColor != color || lastThemeMode != themeMode || lastMaterialVersion != materialVersion) {
      lastTheme = ThemeCustom.getTheme(color: newColor, materialVersion: newMaterialVersion, themeMode: newThemeMode);
      lastColor = newColor;
      lastMaterialVersion = newMaterialVersion;
      lastThemeMode = newThemeMode;
      notifyListeners();
    }
  }

  static const List<Color> colorOptions = [
    Color(0xFFF44336), // Red
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xff6750a4), // m3BaseColor
    Color(0xFF673AB7), // DeepPurple
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF03A9F4), // LightBlue
    Color(0xFF00BCD4), // Cyan
    Color(0xFF009688), // Teal
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // LightGreen
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFFC107), // Amber
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // DeepOrange
    Color(0xFF795548), // Brown
    Color(0xFF9E9E9E), // Grey
    Color(0xFF607D8B), // BlueGrey
  ];
  static const List<String> colorText = <String>[
    "Red",
    "Pink",
    "Purple",
    "DeepPurple",
    "M3 Baseline",
    "Indigo",
    "Blue",
    "LightBlue",
    "Cyan",
    "Teal",
    "Green",
    "LightGreen",
    "Lime",
    "Yellow",
    "Amber",
    "Orange",
    "DeepOrange",
    "Brown",
    "Grey",
    "BlueGrey",
  ];
}
