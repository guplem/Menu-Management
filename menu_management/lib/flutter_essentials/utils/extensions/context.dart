import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";

/// Extensions on [BuildContext] for safe execution checks.
extension BuildContextExtensions on BuildContext {
  /// Executes the given function only if this context is still mounted.
  ///
  /// Logs a warning if the context has been unmounted, helping to catch
  /// potential use-after-dispose issues during development.
  void ifMounted({required Function execute}) async {
    if (mounted) {
      execute.call();
    } else {
      Debug.logWarning(true, "Context is not mounted, skipping execution of ${execute.toString()}", asAssertion: false);
    }
  }
}
