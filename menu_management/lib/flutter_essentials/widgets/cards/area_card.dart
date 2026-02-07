import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/theme/theme_custom.dart";

/// A flat card with the surface color and no elevation.
class AreaCard extends StatelessWidget {
  const AreaCard({super.key, required this.child, this.onTap, this.onLongPress, this.padding});

  final Widget? child;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: padding,
      color: ThemeCustom.colorScheme(context).surface,
      textColor: ThemeCustom.colorScheme(context).onSurface,
      elevation: 0,
      child: child,
    );
  }
}
