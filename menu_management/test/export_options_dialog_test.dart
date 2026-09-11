import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/flutter_essentials/library.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// The texts that the page copied to the clipboard, in the order of the copies.
  late List<String> copiedTexts;

  setUp(() {
    copiedTexts = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
      if (call.method == "Clipboard.setData") copiedTexts.add((call.arguments as Map<Object?, Object?>)["text"]! as String);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  List<ClipboardExportOption> twoOptions() => [
    ClipboardExportOption(
      label: "Simplified",
      description: "The dish of every meal.",
      buildText: () => "simplified text",
      confirmation: "Copied the simplified menu to the clipboard.",
    ),
    ClipboardExportOption(
      label: "Detailed",
      description: "The dish and the time of every meal.",
      buildText: () => "detailed text",
      confirmation: "Copied the detailed menu to the clipboard.",
    ),
  ];

  Future<void> pumpAndOpenDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) {
              return ElevatedButton(
                onPressed: () => showExportOptionsDialog(context: context, title: "Export menu", options: twoOptions()),
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
  });
}
