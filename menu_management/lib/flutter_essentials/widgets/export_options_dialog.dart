import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:menu_management/flutter_essentials/widgets/error_dialog.dart";

/// One row of [showExportOptionsDialog]: one format that the user can pick.
///
/// The row carries its own action, so the dialog stays free of any knowledge about the formats.
/// [ClipboardExportOption] copies a text, and [FileExportOption] writes a file.
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

/// The save call that [FileExportOption] uses. It has the shape of `Persistency.saveBytes`.
/// A test passes its own function here, so no test opens a real save dialog.
typedef SaveBytesCall =
    Future<String?> Function({required List<int> bytes, required String dialogTitle, required String fileName, required String extension});

/// An [ExportOption] that writes a file through a save dialog.
///
/// It is the file counterpart of [ClipboardExportOption]. The class holds no knowledge of any
/// page: the caller passes the bytes, the kind of file, the file name and every message. The
/// caller also passes the two file calls, so this library imports nothing outside itself
/// (ADR 0007).
class FileExportOption extends ExportOption {
  const FileExportOption({
    required super.label,
    required super.description,
    required this.buildBytes,
    required this.dialogTitle,
    required this.defaultFileName,
    required this.buildConfirmation,
    required this.saveBytes,
    required this.supportsFileSaving,
    this.extension = "pdf",
    this.unavailableMessage = defaultUnavailableMessage,
    super.icon = Icons.picture_as_pdf_rounded,
    super.failureNote = "No file was written.",
  });

  /// Builds the bytes of the file. [run] calls it only when the user picks this format, and only
  /// after it knows that the device can save a file.
  final Future<Uint8List> Function() buildBytes;

  /// The title of the save dialog, for example "Select where to save the menu PDF".
  final String dialogTitle;

  /// The file name that the save dialog proposes, for example "Menu-2025-08-06.pdf".
  final String defaultFileName;

  /// The kind of file, for example "pdf". The save dialog filters the folder with it.
  final String extension;

  /// Builds the snackbar text from the path of the written file. The user has to know where the
  /// file went, because a save dialog can put it in any folder.
  final String Function(String path) buildConfirmation;

  /// Writes the file. The menu page passes `Persistency.saveBytes`, and a test passes its own.
  final SaveBytesCall saveBytes;

  /// Says if this device has a save dialog. The menu page passes
  /// `Persistency.supportsFileSaving`, and a test passes its own.
  final bool Function() supportsFileSaving;

  /// What the row reports on iOS and on Android, where `FilePicker` has no save dialog
  /// (ADR 0003). It names the way out, so the user still gets the data out of the app.
  /// Every page that exports something else than the menu passes its own words.
  final String unavailableMessage;

  /// The message of the menu export, which is the only file export of the app today.
  static const String defaultUnavailableMessage = "This device cannot save a file. Copy the menu as text instead.";

  /// Writes the file and returns the snackbar text.
  ///
  /// Returns [unavailableMessage] where the device has no save dialog, and null when the user
  /// closes the dialog. A cancelled save is not a failure, so it shows no snackbar.
  @override
  Future<String?> run() async {
    if (!supportsFileSaving()) return unavailableMessage;

    final Uint8List bytes = await buildBytes();
    final String? path = await saveBytes(bytes: bytes, dialogTitle: dialogTitle, fileName: defaultFileName, extension: extension);
    if (path == null) return null;
    return buildConfirmation(path);
  }
}

/// Shows the export dialog: one row per format, plus a Cancel button.
///
/// A tap on a row runs that format, closes the dialog, and shows the message of that format in a
/// snackbar. A tap on Cancel runs nothing.
///
/// The dialog knows only the rows that the caller gives it. Each row owns its action, so a new
/// format adds one more kind of row and changes nothing in this function.
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
