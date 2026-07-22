import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/cooking_timeline.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";
import "package:menu_management/shopping/owned_amount.dart";
import "package:menu_management/shopping/trip_amount_distributor.dart";

Product _grams({int? shelfLifeDaysClosed, double quantityPerItem = 100}) =>
    Product(link: "https://example.com/g", unit: Unit.grams, quantityPerItem: quantityPerItem, shelfLifeDaysClosed: shelfLifeDaysClosed);

ShoppingTrip _trip(int weekIndex, List<TripItem> items) => ShoppingTrip(weekIndex: weekIndex, items: items);

TripItem _item({String ingredientId = "i", required double amount, Unit unit = Unit.grams, bool freezeOnArrival = false}) =>
    TripItem(ingredientId: ingredientId, amount: amount, unit: unit, freezeOnArrival: freezeOnArrival);

double _sumFor(List<TripAllocation> allocations, Unit unit) {
  double total = 0;
  for (TripAllocation a in allocations) {
    for (Quantity q in a.quantities) {
      if (q.unit == unit) total += q.amount;
    }
  }
  return total;
}

void main() {
  group("distributeRemainingAcrossTrips", () {
    test("returns no allocations when the ingredient is not on any trip", () {
      Ingredient rice = const Ingredient(id: "rice", name: "Rice");
      List<ShoppingTrip> trips = [
        _trip(0, [_item(ingredientId: "beans", amount: 100)]),
      ];

      List<TripAllocation> result = distributeRemainingAcrossTrips(
        ingredient: rice,
        pageRemaining: const [Quantity(amount: 100, unit: Unit.grams)],
        trips: trips,
      );

      expect(result, isEmpty);
    });

    test("multi-trip rounding: per-trip amounts sum to the on-screen whole number (no drift)", () {
      // Page shows 100 g. Planner split the raw need as 33.3 + 33.3 + 33.4 across three weeks.
      // Rounding each line alone gives 33 + 33 + 33 = 99, one short of the page total.
      // The distributor must make the per-trip lines sum to exactly 100.
      Ingredient flour = Ingredient(id: "flour", name: "Flour", products: [_grams()]);
      List<ShoppingTrip> trips = [
        _trip(0, [_item(ingredientId: "flour", amount: 33.3)]),
        _trip(1, [_item(ingredientId: "flour", amount: 33.3)]),
        _trip(2, [_item(ingredientId: "flour", amount: 33.4)]),
      ];

      List<TripAllocation> result = distributeRemainingAcrossTrips(
        ingredient: flour,
        pageRemaining: const [Quantity(amount: 100, unit: Unit.grams)],
        trips: trips,
      );

      expect(_sumFor(result, Unit.grams), 100);
      // Every per-trip amount is a whole number.
      for (TripAllocation a in result) {
        for (Quantity q in a.quantities) {
          expect(q.amount, q.amount.roundToDouble());
        }
      }
    });

    test("different unit: on-screen grams are split across trips even though the planner used pieces", () {
      // Ingredient has gramsPerPiece and only a grams product, so the on-screen list normalizes
      // pieces to grams (page shows 60 g = 12 pieces * 5 g). The planner timeline is still in
      // pieces (4 + 8). The copied per-trip amounts must be in grams and sum to the page's 60 g.
      Ingredient garlic = Ingredient(id: "garlic", name: "Ajo", gramsPerPiece: 5, products: [_grams(quantityPerItem: 150)]);
      List<ShoppingTrip> trips = [
        _trip(0, [_item(ingredientId: "garlic", amount: 4, unit: Unit.pieces)]),
        _trip(1, [_item(ingredientId: "garlic", amount: 8, unit: Unit.pieces)]),
      ];

      List<TripAllocation> result = distributeRemainingAcrossTrips(
        ingredient: garlic,
        pageRemaining: const [Quantity(amount: 60, unit: Unit.grams)],
        trips: trips,
      );

      // All lines are in grams (the on-screen unit), none in pieces.
      expect(result.every((a) => a.quantities.every((q) => q.unit == Unit.grams)), isTrue);
      expect(_sumFor(result, Unit.grams), 60);
      // Weighted by the pieces need: week 0 (4 pieces -> 20 g), week 1 (8 pieces -> 40 g).
      expect(result.firstWhere((a) => a.weekIndex == 0).quantities.first.amount, 20);
      expect(result.firstWhere((a) => a.weekIndex == 1).quantities.first.amount, 40);
    });

    test("carries the freeze-on-arrival flag from the planner's trip items", () {
      Ingredient chicken = Ingredient(id: "chicken", name: "Chicken", products: [_grams(shelfLifeDaysClosed: 3)]);
      List<ShoppingTrip> trips = [
        _trip(0, [_item(ingredientId: "chicken", amount: 200, freezeOnArrival: true)]),
      ];

      List<TripAllocation> result = distributeRemainingAcrossTrips(
        ingredient: chicken,
        pageRemaining: const [Quantity(amount: 200, unit: Unit.grams)],
        trips: trips,
      );

      expect(result.single.freezeOnArrival, isTrue);
    });

    test("defensive: whole page amount lands on the earliest trip when raw weights are all zero", () {
      // Defensive-only path. In production the planner never emits a zero-amount trip item (events with
      // nothing left to buy are skipped), so a present-but-zero-weight week cannot happen through the
      // real flow. This still guards the largest-remainder split's weightSum <= 0 branch directly: if
      // every weight were zero yet the page showed a remaining, it must still land somewhere (trip 0).
      Ingredient flour = Ingredient(id: "flour", name: "Flour", products: [_grams()]);
      List<ShoppingTrip> trips = [
        _trip(0, [_item(ingredientId: "flour", amount: 0)]),
        _trip(1, [_item(ingredientId: "flour", amount: 0)]),
      ];

      List<TripAllocation> result = distributeRemainingAcrossTrips(
        ingredient: flour,
        pageRemaining: const [Quantity(amount: 50, unit: Unit.grams)],
        trips: trips,
      );

      expect(_sumFor(result, Unit.grams), 50);
      expect(result.first.weekIndex, 0);
      expect(result.first.quantities.first.amount, 50);
    });

    test("skips a zero page amount entirely", () {
      Ingredient flour = Ingredient(id: "flour", name: "Flour", products: [_grams()]);
      List<ShoppingTrip> trips = [
        _trip(0, [_item(ingredientId: "flour", amount: 100)]),
      ];

      List<TripAllocation> result = distributeRemainingAcrossTrips(
        ingredient: flour,
        pageRemaining: const [Quantity(amount: 0, unit: Unit.grams)],
        trips: trips,
      );

      expect(result, isEmpty);
    });
  });

  group("copy matches the page end-to-end (planner + distributor)", () {
    test("ingredient with owned stock spanning two units is not dropped from the copy", () {
      // Reachable regression case (issue #34, case 3). Garlic is needed as 4 pieces AND 100 g on the
      // same day, with gramsPerPiece = 25 and both a pieces and a grams product (units stay separate).
      // The user owns 100 g. The on-screen page subtracts the stock once (single grams pool), so it
      // still shows a positive remaining. The old planner subtracted the full 100 g from EACH unit,
      // zeroed every event, produced no trip item, and the distributor then returned nothing -- so the
      // ingredient vanished from the copy while the page still showed a "Need". This test runs the real
      // page flow (computeRemainingQuantities -> planShoppingTrips -> distributeRemainingAcrossTrips)
      // and asserts the copied per-trip amounts sum to exactly what the page shows.
      Ingredient garlic = Ingredient(
        id: "garlic",
        name: "Ajo",
        gramsPerPiece: 25,
        products: [
          _grams(quantityPerItem: 150),
          Product(link: "https://example.com/pc", unit: Unit.pieces, quantityPerItem: 1),
        ],
      );
      const List<Quantity> required = [Quantity(amount: 4, unit: Unit.pieces), Quantity(amount: 100, unit: Unit.grams)];

      List<Quantity> pageRemaining = computeRemainingQuantities(
        ingredient: garlic,
        requiredQuantities: required,
        ownedAmount: 100,
        ownedUnit: Unit.grams,
      );

      // The page shows a positive remaining (200 g of need minus 100 g owned = 100 g still to buy).
      double pageGrams = pageRemaining.fold(0, (double sum, Quantity q) => sum + (garlic.toGrams(q) ?? 0));
      expect(pageGrams, 100);

      Map<String, List<CookingEvent>> timeline = {
        "garlic": [CookingEvent(dayIndex: 0, quantities: required)],
      };
      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [garlic],
        ownedAmounts: const {"garlic": OwnedStock(amount: 100, unit: Unit.grams)},
      );

      List<TripAllocation> allocations = distributeRemainingAcrossTrips(ingredient: garlic, pageRemaining: pageRemaining, trips: trips);

      // The ingredient must appear in the copy, and the copied amounts must sum to the page total.
      expect(allocations, isNotEmpty);
      double copyGrams = 0;
      for (TripAllocation a in allocations) {
        for (Quantity q in a.quantities) {
          copyGrams += garlic.toGrams(q) ?? 0;
        }
      }
      expect(copyGrams, pageGrams);
    });
  });
}
