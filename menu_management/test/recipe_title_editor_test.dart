import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/widgets/recipe_title_editor.dart";

void main() {
  group("RecipeTitleEditor", () {
    const Recipe recipe = Recipe(id: "recipe-1", name: "Tortilla");

    Future<void> pumpEditor(WidgetTester tester, {required void Function(Recipe updatedRecipe) onUpdate}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecipeTitleEditor(recipe: recipe, onUpdate: onUpdate),
        ),
      );
    }

    testWidgets("dialog text is about renaming, not the copy-pasted output picker", (WidgetTester tester) async {
      await pumpEditor(tester, onUpdate: (Recipe updatedRecipe) {});

      expect(find.text("Rename recipe"), findsOneWidget);
      expect(find.text("Name"), findsOneWidget);
      expect(find.text("Select an Output from another step as Input for this"), findsNothing);
      expect(find.text("Output"), findsNothing);
    });

    testWidgets("text field is pre-filled with the recipe name", (WidgetTester tester) async {
      await pumpEditor(tester, onUpdate: (Recipe updatedRecipe) {});

      final TextField textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, "Tortilla");
    });

    testWidgets("save calls onUpdate with the new name and the same id", (WidgetTester tester) async {
      Recipe? result;
      await pumpEditor(tester, onUpdate: (Recipe updatedRecipe) => result = updatedRecipe);

      await tester.enterText(find.byType(TextField), "Tortilla de patatas");
      await tester.pump();
      await tester.tap(find.text("Save"));
      await tester.pump();

      expect(result, isNotNull);
      expect(result!.name, "Tortilla de patatas");
      expect(result!.id, recipe.id);
    });

    testWidgets("save is disabled when the field is empty", (WidgetTester tester) async {
      await pumpEditor(tester, onUpdate: (Recipe updatedRecipe) {});

      await tester.enterText(find.byType(TextField), "");
      await tester.pump();

      final FilledButton saveButton = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(saveButton.onPressed, isNull);
    });
  });
}
