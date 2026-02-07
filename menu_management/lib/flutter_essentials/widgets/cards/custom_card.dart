import "package:flutter/material.dart";
import "package:menu_management/theme/theme_custom.dart";

/// A base card widget with customizable colors, elevation, borders, and tap/long-press callbacks.
///
/// Used as the foundation for [AreaCard], [ElevatedCard], [FilledCard], and [OutlinedCard].
class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.color,
    this.textColor,
    this.elevation,
    this.borderSide,
  });

  final Widget? child;
  final void Function()? onTap;
  final void Function()? onLongPress;
  final EdgeInsets? padding;
  final Color? color, textColor;
  final double? elevation;
  final BorderSide? borderSide;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: kThemeAnimationDuration,
      alignment: Alignment.topCenter,
      child: Card(
        color: color,
        elevation: elevation,
        shape: RoundedRectangleBorder(borderRadius: ThemeCustom.borderRadiusStandard, side: borderSide ?? BorderSide.none),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: ThemeCustom.borderRadiusStandard,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: textColor),
            child: Padding(padding: padding ?? ThemeCustom.paddingInnerCard, child: child),
          ),
        ),
      ),
    );
  }
}
