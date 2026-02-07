import "package:flutter/material.dart";

/// It probably should not be used, check the m3demo for a better implementation
class SwitchButton extends StatefulWidget {
  final bool selected;
  final Widget child;
  final void Function(bool)? onUpdate;

  const SwitchButton({
    Key? key,
    required this.selected,
    required this.child,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<SwitchButton> createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  late bool selected;

  @override
  void initState() {
    selected = widget.selected;
    // print ("Start selected? $widget.startSelected");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selected) {
      return FilledButton(
        //ElevatedButton(
        onPressed: widget.onUpdate == null ? null : switchState,
        // style: ElevatedButton.styleFrom(
        //   // Foreground color
        //   // ignore: deprecated_member_use
        //   onPrimary: ThemeCustom.colorScheme(context).onPrimary,
        //   // Background color
        //   // ignore: deprecated_member_use
        //   primary: ThemeCustom.colorScheme(context).primary,
        // ).copyWith(elevation: ButtonStyleButton.allOrNull(0.0)),
        child: widget.child,
      );
    }
    return OutlinedButton(
      onPressed: widget.onUpdate == null ? null : switchState,
      child: widget.child,
    );
  }

  void switchState() {
    setButtonState(!widget.selected);
  }

  void setButtonState(bool bool) {
    setState(() {
      selected = bool;
      if (widget.onUpdate != null) widget.onUpdate!(bool);
    });
  }
}
