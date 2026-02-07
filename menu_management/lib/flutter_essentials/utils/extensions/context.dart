import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";

extension BuildContextExtensions on BuildContext {
  // https://stackoverflow.com/a/61632770/7927429
  void ifMounted({required Function execute}) async {
    if (mounted) {
      execute.call();
    } else {
      Debug.logWarning(
        true,
        "Context is not mounted, skipping execution of ${execute.toString()}",
        asAssertion: false,
      );
    }
  }
}
