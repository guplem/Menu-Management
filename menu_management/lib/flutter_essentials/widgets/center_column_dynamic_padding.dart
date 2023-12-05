import "package:flutter/material.dart";
import "package:menu_management/theme/theme_custom.dart";

class SmartPaddingCenterColumn extends StatelessWidget {
  final Widget? child;
  final int elevation;
  final bool padding;

  const SmartPaddingCenterColumn({this.elevation = 0, Key? key, this.child, this.padding = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isVertical = MediaQuery.of(context).orientation == Orientation.portrait;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isVertical ? (padding ? ThemeCustom.spaceHorizontal : 0) : (MediaQuery.of(context).size.width - MediaQuery.of(context).size.height) / 1.7 + ThemeCustom.spaceHorizontal * elevation,
      ),
      child: child,
    );
  }
}
