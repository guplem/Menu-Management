import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:menu_management/flutter_essentials/widgets/error_dialog.dart";

/// One row of [showExportOptionsDialog]: one format that the user can pick.
///
/// The row carries its own action, so the dialog stays free of any knowledge about the formats.
/// A later step adds a PDF row as one more subtype, and the pages that call the dialog keep
/// their shape.
abstract class ExportOption {
  const ExportOption({required this.label, required this.description, required this.icon, required this.failureNote});

  /// Names the format in the dialog, for example "Simplified".
  final String label;

  /// Says in one line what the format holds, for example "The dish of every meal.".
  final String description;

  /// The icon of the row. It says what the format does, for example a copy icon.
  final IconData icon;

  /// Says what the failure left behind, for example "Nothing was copied.".
  ///
  /// The dialog writes it in the error message. A format owns this text, because a format that
  /// writes a file copies nothing and must say so in its own words.
  final String failureNote;

  /// Performs the export and returns the snackbar text, for example "Copied ... to the clipboard.".
  ///
  /// Returns null when there is nothing to report, for example when the user cancels a file
  /// picker. The dialog calls it only when the user picks this format, and only once.
  Future<String?> run();
}

/// An [ExportOption] that copies a text to the clipboard.
class ClipboardExportOption extends ExportOption {
  const ClipboardExportOption({
    required super.label,
    required super.description,
    required this.buildText,
    required this.confirmation,
    super.icon = Icons.copy_rounded,
    super.failureNote = "Nothing was copied.",
  });

  /// Builds the text to copy. [run] calls it only when the user picks this format.
  final String Function() buildText;

  /// The snackbar text after the copy, for example "Copied the simplified menu to the clipboard.".
  /// It names the format, so the user knows which one the dialog copied.
  final String confirmation;

  /// Copies the text and returns [confirmation].
  ///
  /// An empty text writes nothing to the clipboard. A copy of an empty text would wipe what the
  /// clipboard holds, and the user would paste nothing and never know why. The message says so.
  @override
  Future<String?> run() async {
    final String text = buildText();
    if (text.isEmpty) return "Nothing to export.";
    await Clipboard.setData(ClipboardData(text: text));
    return confirmation;
  }
}

/// Shows the export dialog: one row per format, plus a Cancel button.
///
/// A tap on a row runs that format, closes the dialog, and shows the message of that format in a
/// snackbar. A tap on Cancel runs nothing.
///
/// The dialog knows only the rows that the caller gives it. Each row owns its action, so a later
/// step that adds a PDF adds one more kind of row here and changes nothing in this function.
///
/// A row that throws shows an error dialog. The export can fail, for example when the menu points
/// at a deleted recipe. This function catches the throw and never rethrows it, so the caller reads
/// no result and no failure of it.
Future<void> showExportOptionsDialog({required BuildContext context, required String title, required List<ExportOption> options}) async {
  final ExportOption? picked = await showDialog<ExportOption>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(title),
        // The rows scroll, because a short window fits only two of them.
        content: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(dialogContext).size.height * 0.6),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (ExportOption option in options)
                  ListTile(
                    leading: Icon(option.icon),
                    title: Text(option.label),
                    subtitle: Text(option.description),
                    onTap: () => Navigator.of(dialogContext).pop(option),
                  ),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text("Cancel"))],
      );
    },
  );

  if (picked == null) return;

  String? message;
  try {
    message = await picked.run();
  } catch (error) {
    if (!context.mounted) return;
    await showErrorDialog(context: context, message: "Could not export the ${picked.label} format. ${picked.failureNote}\n\n$error");
    return;
  }

  if (message == null || !context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
