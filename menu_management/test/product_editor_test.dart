import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/ingredients/widgets/product_editor.dart";

void main() {
  group("ProductEditor number fields", () {
    const Ingredient ingredient = Ingredient(id: "tuna", name: "Tuna");

    Future<void> pumpEditor(
      WidgetTester tester, {
      required void Function(Ingredient updatedIngredient) onUpdate,
      Ingredient editedIngredient = ingredient,
    }) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: ProductEditor(ingredient: editedIngredient, onUpdate: onUpdate),
        ),
      );
    }

    /// Fills the required fields, so only the field under test decides if the form is valid.
    Future<void> fillRequiredFields(WidgetTester tester) async {
      await tester.enterText(find.widgetWithText(TextField, "Product URL"), "https://example.com/tuna");
      await tester.enterText(find.widgetWithText(TextField, "Quantity per item"), "60");
      await tester.pump();
    }

    FilledButton saveButton(WidgetTester tester) => tester.widget<FilledButton>(find.widgetWithText(FilledButton, "Save"));

    ButtonStyleButton addButton(WidgetTester tester) {
      return tester.widget<ButtonStyleButton>(find.ancestor(of: find.text("Add"), matching: find.bySubtype<ButtonStyleButton>()));
    }

    testWidgets("saves the results of arithmetic in the pack and shelf-life fields", (WidgetTester tester) async {
      Ingredient? saved;
      await pumpEditor(tester, onUpdate: (Ingredient updatedIngredient) => saved = updatedIngredient);
      await fillRequiredFields(tester);

      await tester.enterText(find.widgetWithText(TextField, "Items per pack"), "2*3");
      await tester.enterText(find.widgetWithText(TextField, "Shelf life after opening (days)"), "2*7");
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, "Save"));
      await tester.pump();

      expect(saved?.products.single.itemsPerPack, 6);
      expect(saved?.products.single.shelfLifeDaysOpened, 14);
    });

    testWidgets("blocks Save and Add when a shelf-life text does not evaluate to whole days", (WidgetTester tester) async {
      // Without the block, Save would drop the product that the form holds, with no warning.
      await pumpEditor(tester, onUpdate: (Ingredient updatedIngredient) {});
      await fillRequiredFields(tester);

      await tester.enterText(find.widgetWithText(TextField, "Shelf life sealed (days from purchase)"), "10/3");
      await tester.pump();

      expect(saveButton(tester).onPressed, isNull);
      // Add would put a product with no sealed shelf life in the list.
      expect(addButton(tester).onPressed, isNull);
      expect(find.text("Enter a whole number of days"), findsOneWidget);
    });

    testWidgets("blocks Save for an invalid shelf life also after another change", (WidgetTester tester) async {
      // A deleted product is a change, so Save turns on even while the form is not valid. Save then
      // drops the form, so the invalid shelf life must keep Save off.
      const Ingredient withProduct = Ingredient(
        id: "tuna",
        name: "Tuna",
        products: [Product(link: "https://example.com/old", unit: Unit.grams, quantityPerItem: 80, itemsPerPack: 3)],
      );
      await pumpEditor(tester, onUpdate: (Ingredient updatedIngredient) {}, editedIngredient: withProduct);
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();
      await fillRequiredFields(tester);

      await tester.enterText(find.widgetWithText(TextField, "Shelf life sealed (days from purchase)"), "7/");
      await tester.pump();

      expect(saveButton(tester).onPressed, isNull);
    });

    testWidgets("blocks Save when a shelf life is negative", (WidgetTester tester) async {
      await pumpEditor(tester, onUpdate: (Ingredient updatedIngredient) {});
      await fillRequiredFields(tester);

      await tester.enterText(find.widgetWithText(TextField, "Shelf life after opening (days)"), "-3");
      await tester.pump();

      expect(saveButton(tester).onPressed, isNull);
      expect(find.text("Enter a whole number of days"), findsOneWidget);
    });

    testWidgets("shows why the items per pack are not valid", (WidgetTester tester) async {
      await pumpEditor(tester, onUpdate: (Ingredient updatedIngredient) {});
      await fillRequiredFields(tester);

      await tester.enterText(find.widgetWithText(TextField, "Items per pack"), "10/3");
      await tester.pump();

      expect(saveButton(tester).onPressed, isNull);
      expect(find.text("Enter a whole number above 0"), findsOneWidget);
    });

    testWidgets("shows why the quantity per item is not valid", (WidgetTester tester) async {
      await pumpEditor(tester, onUpdate: (Ingredient updatedIngredient) {});
      await fillRequiredFields(tester);

      await tester.enterText(find.widgetWithText(TextField, "Quantity per item"), "60/");
      await tester.pump();

      expect(saveButton(tester).onPressed, isNull);
      expect(find.text("Enter a number above 0"), findsOneWidget);
    });
  });
}
