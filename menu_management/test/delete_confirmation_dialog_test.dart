import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/flutter_essentials/widgets/delete_confirmation_dialog.dart";

void main() {
  group("showDeleteConfirmationDialog", () {
    Future<void> pumpAndOpenDialog(WidgetTester tester, {required void Function(bool confirmed) onResult}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () async {
                    bool confirmed = await showDeleteConfirmationDialog(
                      context: context,
                      title: 'Delete ingredient "Tomato"?',
                      message: "It is used by 2 recipes:",
                      affectedItems: const ["Salad", "Soup"],
                    );
                    onResult(confirmed);
                  },
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

    testWidgets("shows title, message, and the affected items", (WidgetTester tester) async {
      await pumpAndOpenDialog(tester, onResult: (bool confirmed) {});

      expect(find.text('Delete ingredient "Tomato"?'), findsOneWidget);
      expect(find.text("It is used by 2 recipes:"), findsOneWidget);
      expect(find.text("- Salad"), findsOneWidget);
      expect(find.text("- Soup"), findsOneWidget);
    });

    testWidgets("returns true when Delete is tapped", (WidgetTester tester) async {
      bool? result;
      await pumpAndOpenDialog(tester, onResult: (bool confirmed) => result = confirmed);

      await tester.tap(find.text("Delete"));
      await tester.pumpAndSettle();

      expect(result, true);
    });

    testWidgets("returns false when Cancel is tapped", (WidgetTester tester) async {
      bool? result;
      await pumpAndOpenDialog(tester, onResult: (bool confirmed) => result = confirmed);

      await tester.tap(find.text("Cancel"));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets("returns false when dismissed by tapping outside", (WidgetTester tester) async {
      bool? result;
      await pumpAndOpenDialog(tester, onResult: (bool confirmed) => result = confirmed);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(result, false);
    });
  });
}
