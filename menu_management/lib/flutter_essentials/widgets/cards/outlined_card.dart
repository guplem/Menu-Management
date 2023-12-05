import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/theme/theme_custom.dart";

// WaitingForUpdate: Once this issue is completed, delete this class. https://github.com/flutter/flutter/issues/119401
class OutlinedCard extends StatelessWidget {
  const OutlinedCard({Key? key, required this.child, this.onTap, this.padding, this.borderColor}) : super(key: key);

  final Widget? child;
  final void Function()? onTap;
  final EdgeInsets? padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: onTap,
      padding: padding,
      borderSide: BorderSide(color: borderColor ?? ThemeCustom.colorScheme(context).outline),
      elevation: 0,
      // textColor: ThemeCustom.colorScheme(context).onSomething, // Should it be defined? The card uses the default card color with the 0 elevation, so I do not know what color it should be used for the text
      child: child,
    );
  }
}
