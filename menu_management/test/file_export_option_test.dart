import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/flutter_essentials/library.dart";

void main() {
  /// The arguments of every save call, so a test reads what the option asked the picker for.
  late List<({List<int> bytes, String dialogTitle, String fileName, String extension})> saveCalls;

  /// How many times the option built the bytes of the PDF.
  late int buildCount;

  setUp(() {
    saveCalls = [];
    buildCount = 0;
  });

  FileExportOption option({required String? savedPath, bool canSaveFiles = true}) {
    return FileExportOption(
      label: "PDF",
      description: "The whole menu and every recipe.",
      dialogTitle: "Select where to save the menu PDF",
      defaultFileName: "Menu-2025-08-06.pdf",
      extension: "pdf",
      unavailableMessage: "This device cannot save a file. Copy the menu as text instead.",
      icon: Icons.picture_as_pdf_rounded,
      buildBytes: () async {
        buildCount++;
        return Uint8List.fromList(const [37, 80, 68, 70]);
      },
      buildConfirmation: (String path) => "Saved the menu PDF to $path.",
      supportsFileSaving: () => canSaveFiles,
      saveBytes: ({required List<int> bytes, required String dialogTitle, required String fileName, required String extension}) async {
        // The bytes arrive as a Uint8List, and a record compares its runtime types too.
        saveCalls.add((bytes: List<int>.of(bytes), dialogTitle: dialogTitle, fileName: fileName, extension: extension));
        return savedPath;
      },
    );
  }

  group("FileExportOption", () {
    test("writes the kind of file, the icon and the unavailable message that the caller gives it", () async {
      // Every one of these three fields is required, so a page that exports something else than
      // the menu cannot fall back on a message, a file kind or an icon that names the menu.
      FileExportOption shoppingOption({required bool canSaveFiles}) => FileExportOption(
        label: "CSV",
        description: "The shopping list as a table.",
        dialogTitle: "Select where to save the shopping list",
        defaultFileName: "Shopping.csv",
        extension: "csv",
        unavailableMessage: "This device cannot save a file. Copy the shopping list as text instead.",
        icon: Icons.table_chart_rounded,
        buildBytes: () async => Uint8List.fromList(const [65]),
        buildConfirmation: (String path) => "Saved the shopping list to $path.",
        supportsFileSaving: () => canSaveFiles,
        saveBytes: ({required List<int> bytes, required String dialogTitle, required String fileName, required String extension}) async {
          saveCalls.add((bytes: List<int>.of(bytes), dialogTitle: dialogTitle, fileName: fileName, extension: extension));
          return "C:/lists/Shopping.csv";
        },
      );

      expect(await shoppingOption(canSaveFiles: false).run(), "This device cannot save a file. Copy the shopping list as text instead.");
      expect(await shoppingOption(canSaveFiles: true).run(), "Saved the shopping list to C:/lists/Shopping.csv.");
      expect(saveCalls.single.extension, "csv");
      expect(shoppingOption(canSaveFiles: true).icon, Icons.table_chart_rounded);
    });

    test("writes the bytes of the PDF and names the file that it wrote", () async {
      String? message = await option(savedPath: "C:/menus/Menu-2025-08-06.pdf").run();

      expect(message, "Saved the menu PDF to C:/menus/Menu-2025-08-06.pdf.");
      expect(buildCount, 1);
      expect(saveCalls.length, 1);
      expect(saveCalls.single.bytes, const [37, 80, 68, 70]);
      // A record compares its lists by identity, so the three text fields go in one record and the
      // bytes go in the line above.
      expect(
        (saveCalls.single.dialogTitle, saveCalls.single.fileName, saveCalls.single.extension),
        ("Select where to save the menu PDF", "Menu-2025-08-06.pdf", "pdf"),
      );
    });

    test("reports nothing when the user closes the save dialog", () async {
      String? message = await option(savedPath: null).run();

      expect(message, null);
      expect(saveCalls.length, 1);
    });

    test("says that the device cannot save, and builds no bytes, when there is no save dialog", () async {
      String? message = await option(savedPath: "C:/menus/Menu.pdf", canSaveFiles: false).run();

      expect(message, "This device cannot save a file. Copy the menu as text instead.");
      expect(buildCount, 0);
      expect(saveCalls, isEmpty);
    });

    test("carries the failure note of a format that writes a file", () {
      // The note is the one text that every file export shares: a failed write leaves no file.
      expect(option(savedPath: null).failureNote, "No file was written.");
    });
  });
}
