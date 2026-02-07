import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:provider/provider.dart";

/// Retrieves a [Provider] of type [T] from the widget tree.
///
/// When [listen] is false, logs a warning suggesting the singleton pattern
/// for non-listening access (suppressible via [suppressSingletonWarning]).
T getProvider<T>(BuildContext context, {required bool listen, bool suppressSingletonWarning = false}) {
  Debug.logWarning(
    !listen && !suppressSingletonWarning,
    "Trying to get a provider of type $T without listening to it going through the BuildContext. It is recommended to use the singleton pattern instead (instance of the provider).",
  );

  try {
    // Provider.of<X> vs. Consumer<X> https://stackoverflow.com/a/58774889/7927429
    T obtainedProvider = Provider.of<T>(context, listen: listen);
    return obtainedProvider;
  } catch (e) {
    Debug.logError("Error while trying to get a provider of type $T. ${listen ? "Are you sure you want to listen to this provider?" : ""}\n\n$e");
    rethrow;
  }
}
