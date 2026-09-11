import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/flutter_essentials/library.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The texts that the page copied to the clipboard, in the order of the copies.
  late List<String> copiedTexts;

  /// How many times the dialog built the text of each format, keyed by the label of the format.
  late Map<String, int> buildCounts;

  setUp(() {
    copiedTexts = [];
    buildCounts = {"Simplified": 0, "Detailed": 0};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      if (call.method == "Clipboard.setData") copiedTexts.add((call.arguments as Map<Object?, Object?>)["text"]! as String);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  /// Builds the text of one format and counts the call, so a test can check that the dialog
  /// builds only the format that the user picks.
  String countedText({required String label, required String text}) {
    buildCounts[label] = buildCounts[label]! + 1;
    return text;
  }

  List<ExportOption> twoOptions() => [
    ClipboardExportOption(
      label: "Simplified",
      description: "The dish of every meal.",
      buildText: () => countedText(label: "Simplified", text: "simplified text"),
      confirmation: "Copied the simplified menu to the clipboard.",
    ),
    ClipboardExportOption(
      label: "Detailed",
      description: "The dish and the time of every meal.",
      buildText: () => countedText(label: "Detailed", text: "detailed text"),
      confirmation: "Copied the detailed menu to the clipboard.",
    ),
  ];

  Future<void> pumpAndOpenDialog(WidgetTester tester, {List<ExportOption>? options}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () => showExportOptionsDialog(context: context, title: "Export menu", options: options ?? twoOptions()),
                child: const Text("Open"),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text("Open"));
    await tester.pumpAndSettle();
  }

  group("showExportOptionsDialog", () {
    testWidgets("lists the title and every format with its description", (WidgetTester tester) async {
      await pumpAndOpenDialog(tester);

      expect(find.text("Export menu"), findsOneWidget);
      expect(find.text("Simplified"), findsOneWidget);
      expect(find.text("The dish of every meal."), findsOneWidget);
      expect(find.text("Detailed"), findsOneWidget);
      expect(find.text("The dish and the time of every meal."), findsOneWidget);
      expect(find.text("Cancel"), findsOneWidget);
    });

    testWidgets("copies the text of the format that the user picks", (WidgetTester tester) async {
      await pumpAndOpenDialog(tester);

      await tester.tap(find.text("Detailed"));
      await tester.pumpAndSettle();

      expect(copiedTexts, const ["detailed text"]);
    });

    testWidgets("names the copied format in the snackbar and closes the dialog", (WidgetTester tester) async {
      await pumpAndOpenDialog(tester);

      await tester.tap(find.text("Simplified"));
      await tester.pumpAndSettle();

      expect(find.text("Copied the simplified menu to the clipboard."), findsOneWidget);
      expect(find.text("Export menu"), findsNothing);
    });

    testWidgets("copies nothing when the user cancels", (WidgetTester tester) async {
      await pumpAndOpenDialog(tester);

      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();

      expect(copiedTexts, isEmpty);
      expect(find.text("Export menu"), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets("builds only the format that the user picks", (WidgetTester tester) async {
      await pumpAndOpenDialog(tester);

      await tester.tap(find.text("Detailed"));
      await tester.pumpAndSettle();

      expect(buildCounts, const {"Simplified": 0, "Detailed": 1});
    });

    testWidgets("builds no format when the user cancels", (WidgetTester tester) async {
      await pumpAndOpenDialog(tester);

      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();

      expect(buildCounts, const {"Simplified": 0, "Detailed": 0});
    });

    testWidgets("scrolls the rows instead of overflowing when they do not fit", (WidgetTester tester) async {
      // Each row is a two-line ListTile. A short window fits about two of them, and later steps
      // add more rows, so the content must scroll the same way the delete dialog scrolls.
      tester.view.physicalSize = const Size(600, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await pumpAndOpenDialog(
        tester,
        options: [
          for (int i = 0; i < 8; i++)
            ClipboardExportOption(
              label: "Format $i",
              description: "The description of format $i.",
              buildText: () => "text $i",
              confirmation: "Copied $i.",
            ),
        ],
      );

      expect(tester.takeException(), isNull);
      expect(find.descendant(of: find.byType(AlertDialog), matching: find.byType(SingleChildScrollView)), findsOneWidget);
    });
  });

  group("showExportOptionsDialog failed export", () {
    /// One format that throws while it builds its text, the way a stale menu makes the real
    /// builders throw.
    List<ExportOption> throwingOption() => [
      ClipboardExportOption(
        label: "Detailed",
        description: "The dish and the time of every meal.",
        buildText: () => throw StateError("the menu points at a deleted recipe"),
        confirmation: "Copied the detailed menu to the clipboard.",
      ),
    ];

    testWidgets("tells the user that the export failed, and copies nothing", (WidgetTester tester) async {
      await pumpAndOpenDialog(tester, options: throwingOption());

      await tester.tap(find.text("Detailed"));
      await tester.pumpAndSettle();

      expect(copiedTexts, isEmpty);
      expect(find.text("Error"), findsOneWidget);
      expect(find.textContaining("Could not export the Detailed format. Nothing was copied."), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets("writes the failure note of the format that failed", (WidgetTester tester) async {
      // A format that writes a file copies nothing, so the message of the clipboard formats does
      // not fit it. Each format carries its own note.
      await pumpAndOpenDialog(tester, options: [const _ThrowingFileExportOption()]);

      await tester.tap(find.text("File"));
      await tester.pumpAndSettle();

      expect(find.textContaining("Could not export the File format. No file was written."), findsOneWidget);
      expect(find.textContaining("Nothing was copied."), findsNothing);
    });
  });

  group("showExportOptionsDialog empty export", () {
    /// One format whose text is empty, as the simplified shopping list is when the user owns
    /// everything on the menu.
    List<ExportOption> emptyOption() => [
      const ClipboardExportOption(
        label: "Simplified",
        description: "One line per ingredient.",
        buildText: _emptyText,
        confirmation: "Copied the simplified shopping list to the clipboard.",
      ),
    ];

    testWidgets("keeps the clipboard and says that there is nothing to export", (WidgetTester tester) async {
      await pumpAndOpenDialog(tester, options: emptyOption());

      await tester.tap(find.text("Simplified"));
      await tester.pumpAndSettle();

      expect(copiedTexts, isEmpty);
      expect(find.text("Nothing to export."), findsOneWidget);
      expect(find.text("Copied the simplified shopping list to the clipboard."), findsNothing);
    });
  });
}

/// A format that builds no text, for the empty-export test.
String _emptyText() => "";

/// One format that writes a file and fails. It stands for the PDF format of a later step: it
/// copies nothing, so it carries its own failure note.
class _ThrowingFileExportOption extends ExportOption {
  const _ThrowingFileExportOption()
    : super(label: "File", description: "The menu as a file.", icon: Icons.picture_as_pdf_rounded, failureNote: "No file was written.");

  @override
  Future<String?> run() async => throw StateError("the disk is full");
}
