import "package:flutter/material.dart";
import "package:flutter/services.dart";

/// One format of [showExportOptionsDialog]: a text that the dialog copies to the clipboard.
class ClipboardExportOption {
  const ClipboardExportOption({required this.label, required this.description, required this.buildText, required this.confirmation});

  /// Names the format in the dialog, for example "Simplified".
  final String label;

  /// Says in one line what the format holds, for example "The dish of every meal.".
  final String description;

  /// Builds the text to copy. The dialog calls it only when the user picks this format.
  final String Function() buildText;

  /// The snackbar text after the copy, for example "Copied the simplified menu to the clipboard.".
  /// It names the format, so the user knows which one the dialog copied.
  final String confirmation;
}

/// Shows the export dialog: one row per format, plus a Cancel button.
///
/// A tap on a row copies the text of that format to the clipboard, closes the dialog, and shows
/// the confirmation of that format in a snackbar. A tap on Cancel copies nothing.
///
/// The dialog knows only the rows that the caller gives it. A later step that adds a PDF adds one
/// more kind of row here, and the pages that call this function keep their shape.
Future<void> showExportOptionsDialog({required BuildContext context, required String title, required List<ClipboardExportOption> options}) async {
  final ClipboardExportOption? picked = await showDialog<ClipboardExportOption>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (ClipboardExportOption option in options)
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: Text(option.label),
                subtitle: Text(option.description),
                onTap: () => Navigator.of(dialogContext).pop(option),
              ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text("Cancel"))],
      );
    },
  );

  if (picked == null) return;

  await Clipboard.setData(ClipboardData(text: picked.buildText()));

  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(picked.confirmation)));
}
