import "package:flutter/material.dart";

/// Shows a modal error dialog with an OK button.
Future<void> showErrorDialog({required BuildContext context, required String message}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text("OK"))],
      );
    },
  );
}
