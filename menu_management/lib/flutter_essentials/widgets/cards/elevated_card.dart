import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/theme/theme_custom.dart";

/// A card with a slight elevation shadow.
class ElevatedCard extends StatelessWidget {
  const ElevatedCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
  });

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
      elevation: 1,
      child: child,
    );
  }
}
