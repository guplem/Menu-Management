import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/widgets/save_menu_button.dart";

/// A save dialog that fails, the way a broken file picker plugin does.
class _FailingFilePicker extends FilePicker {
  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async => throw Exception("no save dialog");
}

void main() {
  group("SaveMenuButton", () {
    testWidgets("tells the user when the save fails", (WidgetTester tester) async {
      FilePicker.platform = _FailingFilePicker();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(floatingActionButton: SaveMenuButton(buildMenu: () => const MultiWeekMenu())),
        ),
      );

      await tester.tap(find.byTooltip("Save Menu"));
      await tester.pump();

      expect(find.text("Could not save the menu. Exception: no save dialog"), findsOneWidget);
    });
  });
}
