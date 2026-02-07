import "package:flutter/material.dart";
import "package:menu_management/theme/theme_custom.dart";

// WaitingForUpdate: Once this issue is completed, delete this class. https://github.com/flutter/flutter/issues/111800
// https://m3.material.io/components/icon-buttons/specs#c2ca424b-2ad7-40e6-8946-47fb1918060a
class IconButtonFilledTonal extends StatelessWidget {
  const IconButtonFilledTonal({
    Key? key,
    required this.onPressed,
    required this.icon,
  }) : super(key: key);

  final void Function()? onPressed;
  final Widget icon;

  ButtonStyle getStyle(BuildContext context) {
    ColorScheme colorScheme = ThemeCustom.colorScheme(context);

    if (onPressed == null) {
      return IconButton.styleFrom(
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
      );
    }

    return IconButton.styleFrom(
      foregroundColor: colorScheme.onSecondaryContainer,
      backgroundColor: colorScheme.secondaryContainer,
      hoverColor: colorScheme.onSecondaryContainer.withValues(alpha: 0.08),
      focusColor: colorScheme.onSecondaryContainer.withValues(alpha: 0.12),
      highlightColor: colorScheme.onSecondaryContainer.withValues(alpha: 0.12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: getStyle(context),
      onPressed: onPressed,
      icon: icon,
    );
  }
}
