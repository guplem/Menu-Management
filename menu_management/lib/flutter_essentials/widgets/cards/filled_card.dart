import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/theme/theme_custom.dart";

// WaitingForUpdate: Once this issue is completed, delete this class. https://github.com/flutter/flutter/issues/119401
class FilledCard extends StatelessWidget {
  const FilledCard({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
    this.color,
    this.textColor,
    this.outlined = false,
    this.borderColor,
  }) : super(key: key);

  final Widget? child;
  final void Function()? onTap;
  final EdgeInsets? padding;
  final Color? color, textColor, borderColor;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: padding,
      color:
          color ??
          ThemeCustom.colorScheme(
            context,
          ).secondaryContainer, // Material3 Specs are with surfaceVariant, but secondaryContainer looks better IMO
      textColor:
          textColor ??
          ThemeCustom.colorScheme(
            context,
          ).onSecondaryContainer, // Material3 Specs are with onSurfaceVariant, but looks better IMO
      borderSide: !outlined
          ? null
          : BorderSide(
              color: borderColor ?? ThemeCustom.colorScheme(context).outline,
            ),
      elevation: 0,
      child: child,
    );
  }
}
