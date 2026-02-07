import "dart:ui";

import "package:flutter/material.dart";
import "package:menu_management/theme/dynamic_theme.dart";

class ThemeCustom {
  ThemeCustom._();

  // ROOT VALUES
  /// Space that must exist between cards (from M3 specs)
  static const double spaceVertical = 8; //Should be 8
  /// An in-between space intended to be used when an equal (horizontally and vertically) padding is needed
  static const double spaceSquared = spaceVertical * 1.5; //Should be 12
  /// Used for padding a whole page or elements inside elements (like cards in a full-page scaffold)
  static const double spaceHorizontal = spaceVertical * 1.6; //Originally, it was intended to be 16, but it felt like too much
  /// Used to separate element that are in the same horizontal row one next to the other
  static const double spaceInlineHorizontal = spaceVertical; //Should be 16

  //COMMON SPACES
  /// https://m3.material.io/components/cards/specs#:~:text=16dp-,Padding%20between%20cards,-8dp%20max (M3 specs)
  static const double spaceBetweenCards = spaceVertical; //Should be 8

  // COMMON PADDINGS
  static const EdgeInsets paddingVertical = EdgeInsets.symmetric(vertical: spaceVertical);
  static const EdgeInsets paddingHorizontal = EdgeInsets.symmetric(horizontal: spaceHorizontal);
  static const EdgeInsets paddingFullPage = EdgeInsets.symmetric(vertical: spaceVertical, horizontal: spaceHorizontal);
  static const EdgeInsets paddingSquaredStandard = EdgeInsets.all(spaceSquared);
  static const EdgeInsets paddingStandard = EdgeInsets.symmetric(horizontal: spaceHorizontal, vertical: spaceVertical);
  static const EdgeInsets paddingInnerCard = EdgeInsets.symmetric(horizontal: spaceVertical * 1.25, vertical: spaceVertical * 1.25);

  // STANDARD BORDER RADIUS
  static BorderRadius borderRadiusStandard = BorderRadius.circular(borderRadiusStandardValue);
  static BorderRadius borderRadiusFullyRounded = BorderRadius.circular(999999);
  static double borderRadiusStandardValue = 12; //INFO: https://m3.material.io/styles/shape/shape-scale-tokens

  // THEME SETTINGS
  static ThemeData get defaultTheme => getTheme(color: defaultSeedColor, themeMode: defaultThemeMode, materialVersion: defaultMaterialVersion);
  static Color get defaultSeedColor => DynamicTheme.colorOptions[9]; // Teal
  static ThemeMode get defaultThemeMode => ThemeMode.system;
  static int get defaultMaterialVersion => 3;

  static ThemeData getTheme({required Color color, int materialVersion = 3, ThemeMode themeMode = ThemeMode.system}) {
    bool useLightMode = true;
    switch (themeMode) {
      case ThemeMode.system:
        useLightMode = PlatformDispatcher.instance.platformBrightness == Brightness.light;
        break;
      case ThemeMode.dark:
        useLightMode = false;
        break;
      case ThemeMode.light:
        useLightMode = true;
        break;
    }

    ThemeData themeData = ThemeData(
      typography: Typography.material2021(),
      colorSchemeSeed: color,
      useMaterial3: materialVersion == 3,
      brightness: useLightMode ? Brightness.light : Brightness.dark,
    );

    if (materialVersion == 3) {
      Color surfaceColor = ElevationOverlay.applySurfaceTint(themeData.colorScheme.surface, themeData.colorScheme.surfaceTint, 1);
      themeData = themeData.copyWith(
        colorScheme: themeData.colorScheme.copyWith(surface: surfaceColor, onSurface: themeData.colorScheme.onSurfaceVariant),
      );
    }

    return themeData;
  }

  // THEME SHORTCUTS
  static ThemeData of(BuildContext context) => Theme.of(context);

  static ColorScheme colorScheme(BuildContext context) => ThemeCustom.of(context).colorScheme;

  static TextTheme textTheme(BuildContext context) => ThemeCustom.of(context).textTheme;

  static SliderThemeData sliderTheme(BuildContext context) => SliderTheme.of(context);
}
