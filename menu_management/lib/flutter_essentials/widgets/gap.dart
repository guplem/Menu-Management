import "package:flutter/material.dart";
import "package:menu_management/theme/theme_custom.dart";

class Gap extends StatelessWidget {
  final double width;
  final double height;
  final Widget? child;

  const Gap.vertical({super.key, this.child})
      : width = 0,
        height = ThemeCustom.spaceVertical;

  const Gap.verticalNewSection({super.key, this.child})
      : width = 0,
        height = ThemeCustom.spaceVertical * 2;

  const Gap.horizontal({super.key, this.child})
      : width = ThemeCustom.spaceVertical,
        height = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height, width: width, child: child);
  }
}
