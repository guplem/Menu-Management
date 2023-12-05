import "package:flutter/material.dart";

class FloatingButtonVisibility extends StatelessWidget {
  const FloatingButtonVisibility({Key? key, this.duration = kThemeAnimationDuration, required this.visible, required this.child}) : super(key: key);

  final Duration duration;
  final bool visible;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: duration,
      offset: visible ? Offset.zero : const Offset(0, 2),
      child: AnimatedOpacity(
        duration: duration,
        opacity: visible ? 1 : 0,
        child: child,
      ),
    );
  }
}
