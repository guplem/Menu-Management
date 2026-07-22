import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";
import "package:menu_management/shopping/shopping_ingredient.dart";

// 100 grams per pack (2 items x 50 grams), so itemsPerPack > 1 keeps the "pack(s)" wording.
Product _packProduct() => const Product(link: "", quantityPerItem: 50, itemsPerPack: 2, unit: Unit.grams);

Ingredient _ingredient() => Ingredient(id: "beans", name: "Beans", products: [_packProduct()]);

ShoppingTrip _trip(int weekIndex, List<TripItem> items) => ShoppingTrip(weekIndex: weekIndex, items: items);

TripItem _item({String ingredientId = "beans", required double amount, bool freezeOnArrival = false}) =>
    TripItem(ingredientId: ingredientId, amount: amount, unit: Unit.grams, freezeOnArrival: freezeOnArrival);

/// Pumps [ShoppingIngredient] in isolation with real [plannedTrips], so the assertions
/// exercise `_tripPurchasesForProduct` (the split computation), not hand-built purchases.
Future<void> _pumpIngredient(WidgetTester tester, {required double remainingGrams, required List<ShoppingTrip> plannedTrips}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ShoppingIngredient(
          ingredient: _ingredient(),
          quantitiesDesired: const [Quantity(amount: 900, unit: Unit.grams)],
          calculatedRemainingQuantities: [Quantity(amount: remainingGrams, unit: Unit.grams)],
          productRecommendations: const [],
          ownedAmount: 0,
          ownedUnit: const OwnedUnit(),
          onOwnedChanged: (double amount, OwnedUnit unit) {},
          sources: const [],
          plannedTrips: plannedTrips,
        ),
      ),
    ),
  );
}

void main() {
  group("ShoppingIngredient per-trip buy split", () {
    testWidgets("renders the split lines when 2+ trips buy the product", (WidgetTester tester) async {
      // Week 0 buys 600 g (6 packs), week 1 buys 300 g (3 packs), 900 g total (9 packs).
      await _pumpIngredient(
        tester,
        remainingGrams: 900,
        plannedTrips: [
          _trip(0, [_item(amount: 600)]),
          _trip(1, [_item(amount: 300)]),
        ],
      );

      expect(find.text("Buy 6 packs now"), findsOneWidget);
      expect(find.text("+ 3 packs week 2"), findsOneWidget);
      // The single-total label must not appear when the row is split.
      expect(find.text("Buy 9 packs"), findsNothing);
    });

    testWidgets("renders a single total line for a single-trip plan", (WidgetTester tester) async {
      await _pumpIngredient(
        tester,
        remainingGrams: 600,
        plannedTrips: [
          _trip(0, [_item(amount: 600)]),
        ],
      );

      expect(find.text("Buy 6 packs"), findsOneWidget);
      expect(find.textContaining("week"), findsNothing);
      expect(find.textContaining("now"), findsNothing);
    });

    testWidgets("shows no split when 3 trips exist but only 1 buys the product", (WidgetTester tester) async {
      // Two of the three trips buy a different ingredient, so only one trip matches this product.
      await _pumpIngredient(
        tester,
        remainingGrams: 600,
        plannedTrips: [
          _trip(0, [_item(amount: 600)]),
          _trip(1, [_item(ingredientId: "rice", amount: 600)]),
          _trip(2, [_item(ingredientId: "rice", amount: 600)]),
        ],
      );

      expect(find.text("Buy 6 packs"), findsOneWidget);
      expect(find.textContaining("week"), findsNothing);
      expect(find.textContaining("now"), findsNothing);
    });

    testWidgets("skips trips whose rounded amount yields 0 packs, avoiding a false split", (WidgetTester tester) async {
      // Only week 0 has a real amount; the other two round to 0 packs and are skipped.
      await _pumpIngredient(
        tester,
        remainingGrams: 600,
        plannedTrips: [
          _trip(0, [_item(amount: 600)]),
          _trip(1, [_item(amount: 0.4)]),
          _trip(2, [_item(amount: 0.3)]),
        ],
      );

      expect(find.text("Buy 6 packs"), findsOneWidget);
      expect(find.textContaining("week"), findsNothing);
      expect(find.textContaining("now"), findsNothing);
    });
  });

  group("ShoppingIngredient freeze on arrival note", () {
    testWidgets("shows the note when the planner marks this ingredient to freeze on arrival", (WidgetTester tester) async {
      await _pumpIngredient(
        tester,
        remainingGrams: 600,
        plannedTrips: [
          _trip(0, [_item(amount: 600, freezeOnArrival: true)]),
        ],
      );

      // Matches the "(freeze on arrival)" suffix in the copied list.
      expect(find.text("freeze on arrival"), findsOneWidget);
    });

    testWidgets("hides the note when no trip marks this ingredient to freeze", (WidgetTester tester) async {
      await _pumpIngredient(
        tester,
        remainingGrams: 600,
        plannedTrips: [
          _trip(0, [_item(amount: 600)]),
        ],
      );

      expect(find.text("freeze on arrival"), findsNothing);
    });

    testWidgets("hides the note when only a different ingredient must be frozen", (WidgetTester tester) async {
      await _pumpIngredient(
        tester,
        remainingGrams: 600,
        plannedTrips: [
          _trip(0, [_item(amount: 600), _item(ingredientId: "rice", amount: 600, freezeOnArrival: true)]),
        ],
      );

      expect(find.text("freeze on arrival"), findsNothing);
    });
  });
}
