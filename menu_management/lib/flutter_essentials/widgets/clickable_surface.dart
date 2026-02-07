import "package:flutter/material.dart";

class ClickableSurface extends StatelessWidget {
  const ClickableSurface({super.key, required this.child, this.onTap});

  final Widget child;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null
            ? WidgetStateMouseCursor.clickable
            : SystemMouseCursors.forbidden,
        child: child,
      ),
    );
  }
}
