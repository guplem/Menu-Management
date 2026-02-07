import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";

class LoadingSpinnerIndicator extends StatelessWidget {
  /// Use Small for buttons, inline loading indicators, ...
  const LoadingSpinnerIndicator({Key? key, this.text, this.small = false})
    : super(key: key);

  final String? text;
  final bool small;

  @override
  Widget build(BuildContext context) {
    // https://stackoverflow.com/a/66711802/7927429
    if (small) {
      return SizedBox(height: 15, width: 15, child: getInner());
    }
    return getInner();
  }

  static Widget getSpinner() {
    return const CircularProgressIndicator.adaptive();
  }

  Widget getInner() {
    if (text == null) {
      return getSpinner();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        getSpinner(),
        if (text != null) const Gap.vertical(),
        if (text != null) Text(text!),
      ],
    );
  }
}

class LoadingSpinnerIndicatorFullscreen extends StatelessWidget {
  const LoadingSpinnerIndicatorFullscreen({Key? key, this.text})
    : super(key: key);

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Center(child: getInner());
  }

  Widget getInner() {
    if (text == null) {
      return LoadingSpinnerIndicator.getSpinner();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        LoadingSpinnerIndicator.getSpinner(),
        if (text != null) const Gap.vertical(),
        if (text != null) Text(text!),
      ],
    );
  }
}
