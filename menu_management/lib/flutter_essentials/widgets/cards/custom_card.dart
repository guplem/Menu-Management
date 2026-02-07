import "package:flutter/material.dart";
import "package:menu_management/theme/theme_custom.dart";

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.textColor,
    this.elevation,
    this.borderSide,
  });

  final Widget? child;
  final void Function()? onTap;
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
        shape: RoundedRectangleBorder(
          borderRadius: ThemeCustom.borderRadiusStandard,
          side: borderSide ?? BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: ThemeCustom.borderRadiusStandard,
          child: DefaultTextStyle.merge(
            style: TextStyle(color: textColor),
            child: Padding(
              padding: padding ?? ThemeCustom.paddingInnerCard,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
