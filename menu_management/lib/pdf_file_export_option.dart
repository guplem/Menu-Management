import "dart:typed_data";

import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/persistency.dart";

/// The save call that [PdfFileExportOption] uses. It has the shape of [Persistency.saveBytes].
/// A test passes its own function here, so no test opens a real save dialog.
typedef SaveBytesCall =
    Future<String?> Function({required List<int> bytes, required String dialogTitle, required String fileName, required String extension});

/// An [ExportOption] that writes a PDF file through a save dialog.
///
/// It is the file counterpart of `ClipboardExportOption`: the dialog stays the same, and this row
/// owns everything that a file needs. The shopping page of a later step reuses it, so the class
/// holds no menu knowledge: the caller passes the bytes, the file name and the messages.
class PdfFileExportOption extends ExportOption {
  const PdfFileExportOption({
    required super.label,
    required super.description,
    required this.buildBytes,
    required this.dialogTitle,
    required this.defaultFileName,
    required this.buildConfirmation,
    super.icon = Icons.picture_as_pdf_rounded,
    super.failureNote = "No file was written.",
    this.saveBytes = Persistency.saveBytes,
    this.supportsFileSaving = Persistency.supportsFileSaving,
  });

  /// Builds the bytes of the PDF. [run] calls it only when the user picks this format, and only
  /// after it knows that the device can save a file.
  final Future<Uint8List> Function() buildBytes;

  /// The title of the save dialog, for example "Select where to save the menu PDF".
  final String dialogTitle;

  /// The file name that the save dialog proposes, for example "Menu-2025-08-06.pdf".
  final String defaultFileName;

  /// Builds the snackbar text from the path of the written file. The user has to know where the
  /// file went, because a save dialog can put it in any folder.
  final String Function(String path) buildConfirmation;

  /// Writes the file. It defaults to [Persistency.saveBytes] and exists as a field for the tests.
  final SaveBytesCall saveBytes;

  /// Says if this device has a save dialog. It defaults to [Persistency.supportsFileSaving] and
  /// exists as a field for the tests.
  final bool Function() supportsFileSaving;

  /// What the row reports on iOS and on Android, where `FilePicker` has no save dialog (ADR 0003).
  /// It names the way out, so the user still gets the menu out of the app.
  static const String unavailableMessage = "This device cannot save a file. Copy the menu as text instead.";

  /// Writes the PDF and returns the snackbar text.
  ///
  /// Returns [unavailableMessage] where the device has no save dialog, and null when the user
  /// closes the dialog. A cancelled save is not a failure, so it shows no snackbar.
  @override
  Future<String?> run() async {
    if (!supportsFileSaving()) return unavailableMessage;

    final Uint8List bytes = await buildBytes();
    final String? path = await saveBytes(bytes: bytes, dialogTitle: dialogTitle, fileName: defaultFileName, extension: "pdf");
    if (path == null) return null;
    return buildConfirmation(path);
  }
}
