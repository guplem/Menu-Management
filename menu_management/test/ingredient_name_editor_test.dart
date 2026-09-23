import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/widgets/ingredient_name_editor.dart";

void main() {
  group("IngredientNameEditor number fields", () {
    const Ingredient ingredient = Ingredient(id: "yogurt", name: "Yogurt");

    Future<void> pumpEditor(WidgetTester tester, {required void Function(Ingredient updatedIngredient) onUpdate}) async {
      await tester.pumpWidget(
        MaterialApp(
          home: IngredientNameEditor(ingredient: ingredient, onUpdate: onUpdate),
        ),
      );
    }

    FilledButton saveButton(WidgetTester tester) => tester.widget<FilledButton>(find.widgetWithText(FilledButton, "Save"));

    testWidgets("saves the result of an arithmetic density", (WidgetTester tester) async {
      Ingredient? saved;
      await pumpEditor(tester, onUpdate: (Ingredient updatedIngredient) => saved = updatedIngredient);

      await tester.enterText(find.widgetWithText(TextField, "Density (g/ml)"), "21/20");
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, "Save"));
      await tester.pump();

      expect(saved?.density, 1.05);
    });

    testWidgets("blocks Save when the density text does not evaluate", (WidgetTester tester) async {
      // Without the block, Save would store no density and remove the one that the ingredient had.
      await pumpEditor(tester, onUpdate: (Ingredient updatedIngredient) {});

      await tester.enterText(find.widgetWithText(TextField, "Density (g/ml)"), "1/");
      await tester.pump();

      expect(saveButton(tester).onPressed, isNull);
      expect(find.text("Enter a number above 0"), findsOneWidget);
    });

    testWidgets("blocks Save when the grams per piece are not above 0", (WidgetTester tester) async {
      await pumpEditor(tester, onUpdate: (Ingredient updatedIngredient) {});

      await tester.enterText(find.widgetWithText(TextField, "Grams per piece"), "5-10");
      await tester.pump();

      expect(saveButton(tester).onPressed, isNull);
      expect(find.text("Enter a number above 0"), findsOneWidget);
    });

    testWidgets("allows Save when the optional number fields are empty", (WidgetTester tester) async {
      await pumpEditor(tester, onUpdate: (Ingredient updatedIngredient) {});

      expect(saveButton(tester).onPressed, isNotNull);
      expect(find.text("Enter a number above 0"), findsNothing);
    });
  });
}
