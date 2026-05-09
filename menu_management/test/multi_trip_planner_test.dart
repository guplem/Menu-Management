import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/cooking_timeline.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";

Product _product({
  Unit unit = Unit.grams,
  int? shelfLifeDaysClosed,
  double quantityPerItem = 100,
  int itemsPerPack = 1,
  bool canBeFrozen = false,
}) {
  return Product(
    link: "https://example.com/p",
    unit: unit,
    quantityPerItem: quantityPerItem,
    itemsPerPack: itemsPerPack,
    shelfLifeDaysClosed: shelfLifeDaysClosed,
    canBeFrozen: canBeFrozen,
  );
}

Ingredient _ingredient({required String id, String? name, List<Product> products = const []}) {
  return Ingredient(id: id, name: name ?? id, products: products);
}

CookingEvent _event({required int day, double amount = 100, Unit unit = Unit.grams}) {
  return CookingEvent(dayIndex: day, quantities: [Quantity(amount: amount, unit: unit)]);
}

void main() {
  group("planShoppingTrips", () {
    test("returns no trips when timeline is empty", () {
      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: const {},
        ingredients: const [],
      );

      expect(trips, isEmpty);
    });

    test("non-perishable single ingredient produces one trip on week 0", () {
      Ingredient banana = _ingredient(id: "banana", products: [_product()]); // no shelf life
      Map<String, List<CookingEvent>> timeline = {
        "banana": [_event(day: 2, amount: 200)], // monday week 1
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [banana],
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 0);
      expect(trips.first.tripDay, -1);
      expect(trips.first.items.length, 1);
      expect(trips.first.items.first.ingredientId, "banana");
      expect(trips.first.items.first.amount, 200);
      expect(trips.first.items.first.unit, Unit.grams);
    });

    test("ingredient with no products is treated as non-perishable", () {
      Ingredient salt = _ingredient(id: "salt"); // no products at all
      Map<String, List<CookingEvent>> timeline = {
        "salt": [_event(day: 14, amount: 50)], // week 3
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [salt],
      );

      expect(trips.length, 1);
      // Single non-perishable, no perishables to anchor to → trip 0
      expect(trips.first.weekIndex, 0);
    });

    test("perishable used in week 2 only that cannot survive trip 0 forces trip 1", () {
      // Banana with 5-day closed shelf life, used on day 7 (saturday week 2).
      // Trip 0 at day -1: 7 - (-1) = 8 days from purchase, exceeds 5 → expired.
      // Trip 1 at day 6: 7 - 6 = 1 day from purchase, fresh.
      Ingredient banana = _ingredient(id: "banana", products: [_product(shelfLifeDaysClosed: 5)]);
      Map<String, List<CookingEvent>> timeline = {
        "banana": [_event(day: 7, amount: 200)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [banana],
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 1);
      expect(trips.first.tripDay, 6);
      expect(trips.first.items.first.ingredientId, "banana");
    });

    test("non-perishable in week 1 + perishable in week 2 produces two trips", () {
      Ingredient salt = _ingredient(id: "salt"); // non-perishable
      Ingredient banana = _ingredient(id: "banana", products: [_product(shelfLifeDaysClosed: 5)]);
      Map<String, List<CookingEvent>> timeline = {
        "salt": [_event(day: 2, amount: 50)],
        "banana": [_event(day: 7, amount: 200)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [salt, banana],
      );

      expect(trips.length, 2);
      expect(trips[0].weekIndex, 0);
      expect(trips[1].weekIndex, 1);
      expect(trips[0].items.map((i) => i.ingredientId), contains("salt"));
      expect(trips[1].items.map((i) => i.ingredientId), contains("banana"));
    });

    test("non-perishable used in week 3 hitches on existing earliest trip rather than adding trip 0", () {
      // Perishable forces trip 1. Non-perishable in week 3 has interval [0, 2] → trip 1 covers it.
      Ingredient banana = _ingredient(id: "banana", products: [_product(shelfLifeDaysClosed: 5)]);
      Ingredient salt = _ingredient(id: "salt");
      Map<String, List<CookingEvent>> timeline = {
        "banana": [_event(day: 7, amount: 200)], // forces trip 1
        "salt": [_event(day: 14, amount: 30)],   // non-perishable, week 3
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [banana, salt],
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 1);
      expect(trips.first.items.length, 2);
    });

    test("same ingredient used in two distant weeks with short shelf life splits across two trips", () {
      // Banana used on day 2 and day 9. Shelf life 5 days closed.
      // Day 2: trip 0 (-1) gives 3 days → fresh. latestW=0.
      // Day 9: trip 0 gives 10 days → expired. Trip 1 (6) gives 3 days → fresh. earliestW=1.
      Ingredient banana = _ingredient(id: "banana", products: [_product(shelfLifeDaysClosed: 5)]);
      Map<String, List<CookingEvent>> timeline = {
        "banana": [_event(day: 2, amount: 100), _event(day: 9, amount: 150)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [banana],
      );

      expect(trips.length, 2);
      ShoppingTrip trip0 = trips.firstWhere((t) => t.weekIndex == 0);
      ShoppingTrip trip1 = trips.firstWhere((t) => t.weekIndex == 1);
      expect(trip0.items.first.amount, 100);
      expect(trip1.items.first.amount, 150);
    });

    test("ingredient used mid-week with shelf life that allows bundling stays on the week's trip", () {
      // Day 10 (mid-week 2). Shelf life closed = 6 days.
      // Trip 0 (-1) → 11 days from purchase → expired.
      // Trip 1 (6) → 4 days from purchase → fresh. earliestW=1, latestW=1.
      Ingredient lettuce = _ingredient(id: "lettuce", products: [_product(shelfLifeDaysClosed: 6)]);
      Ingredient bread = _ingredient(id: "bread", products: [_product(shelfLifeDaysClosed: 7)]);
      Map<String, List<CookingEvent>> timeline = {
        "lettuce": [_event(day: 10, amount: 50)],
        // Bread on day 8, shelf life 7. Trip 0: 9 days expired. Trip 1: 2 days fresh. Forces trip 1.
        "bread": [_event(day: 8, amount: 100)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [lettuce, bread],
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 1);
      expect(trips.first.items.length, 2);
    });

    test("aggregates multiple events of the same ingredient onto the same trip", () {
      Ingredient flour = _ingredient(id: "flour"); // non-perishable
      Map<String, List<CookingEvent>> timeline = {
        "flour": [_event(day: 1, amount: 100), _event(day: 4, amount: 200)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [flour],
      );

      expect(trips.length, 1);
      expect(trips.first.items.length, 1);
      expect(trips.first.items.first.amount, 300);
    });

    test("owned amount consumed against earliest events first", () {
      Ingredient banana = _ingredient(id: "banana", products: [_product(shelfLifeDaysClosed: 5)]);
      // Two events: day 2 (100g), day 9 (150g). Owned 100g.
      // Owned covers day-2 fully, leaves day-9 needing 150g.
      // Day-9 forces trip 1.
      Map<String, List<CookingEvent>> timeline = {
        "banana": [_event(day: 2, amount: 100), _event(day: 9, amount: 150)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [banana],
        ownedAmounts: const {
          "banana": [Quantity(amount: 100, unit: Unit.grams)],
        },
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 1);
      expect(trips.first.items.first.amount, 150);
    });

    test("owned amount partially covering an event leaves only the remainder", () {
      Ingredient flour = _ingredient(id: "flour");
      Map<String, List<CookingEvent>> timeline = {
        "flour": [_event(day: 0, amount: 250)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [flour],
        ownedAmounts: const {
          "flour": [Quantity(amount: 100, unit: Unit.grams)],
        },
      );

      expect(trips.length, 1);
      expect(trips.first.items.first.amount, 150);
    });

    test("owned amount in non-matching unit does not subtract from a different-unit event", () {
      Ingredient banana = _ingredient(id: "banana");
      // Recipe uses grams; owned is in pieces. Without conversion, no subtraction.
      Map<String, List<CookingEvent>> timeline = {
        "banana": [_event(day: 0, amount: 200, unit: Unit.grams)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [banana],
        ownedAmounts: const {
          "banana": [Quantity(amount: 3, unit: Unit.pieces)],
        },
      );

      expect(trips.first.items.first.amount, 200);
      expect(trips.first.items.first.unit, Unit.grams);
    });

    test("event whose shelf life cannot be satisfied by any prior trip falls back to closest trip", () {
      // Shelf life 1 day, event on day 10. No trip satisfies fresh constraint:
      // Trip 0 (-1): 11 days → expired. Trip 1 (6): 4 days → expired. Trip 2 (13): purchase after use.
      // Latest trip <= 10 is W=1 (day 6). Falls back to W=1.
      Ingredient mushroom = _ingredient(id: "mushroom", products: [_product(shelfLifeDaysClosed: 1)]);
      Map<String, List<CookingEvent>> timeline = {
        "mushroom": [_event(day: 10, amount: 100)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [mushroom],
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 1);
    });

    test("multiple shelf-life products on one ingredient: planner uses product matching the event's unit", () {
      // Banana sold both as grams (5-day shelf life) and pieces (no shelf life).
      // Recipe uses pieces → no shelf life constraint → can go on trip 0.
      Ingredient banana = _ingredient(
        id: "banana",
        products: [
          _product(unit: Unit.grams, shelfLifeDaysClosed: 5),
          _product(unit: Unit.pieces),
        ],
      );
      Map<String, List<CookingEvent>> timeline = {
        "banana": [_event(day: 14, amount: 3, unit: Unit.pieces)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [banana],
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 0);
      expect(trips.first.items.first.unit, Unit.pieces);
    });

    test("items within a trip are sorted alphabetically by ingredient name", () {
      Ingredient zucchini = _ingredient(id: "z", name: "Zucchini");
      Ingredient apple = _ingredient(id: "a", name: "Apple");
      Ingredient mango = _ingredient(id: "m", name: "Mango");
      Map<String, List<CookingEvent>> timeline = {
        "z": [_event(day: 0, amount: 100)],
        "a": [_event(day: 0, amount: 100)],
        "m": [_event(day: 0, amount: 100)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [zucchini, apple, mango],
      );

      expect(trips.length, 1);
      expect(trips.first.items.map((i) => i.ingredientId).toList(), ["a", "m", "z"]);
    });

    test("trip count is capped at the number of menu weeks (3-week menu cannot produce trip 3)", () {
      // Day 20 = Friday of week 3, last day of a 3-week menu. Shelf life closed = 1 day.
      // Trip 2 (day 13) is 7 days early -> expired. Trip 3 (day 20) would be same day,
      // but the menu only spans 3 weeks (max weekIndex = 2). The planner must NOT add a
      // 4th trip; it falls back to trip 2 with the existing menu expiry warning surfacing
      // the staleness elsewhere.
      Ingredient herb = _ingredient(id: "herb", products: [_product(shelfLifeDaysClosed: 1)]);
      Map<String, List<CookingEvent>> timeline = {
        "herb": [_event(day: 20, amount: 50)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [herb],
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, lessThanOrEqualTo(2));
    });

    test("trips are returned sorted by weekIndex ascending", () {
      Ingredient meat = _ingredient(id: "meat", products: [_product(shelfLifeDaysClosed: 2)]);
      Map<String, List<CookingEvent>> timeline = {
        // Three events forcing three different trips
        "meat": [_event(day: 0, amount: 100), _event(day: 7, amount: 100), _event(day: 14, amount: 100)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [meat],
      );

      expect(trips.length, 3);
      expect(trips[0].weekIndex, 0);
      expect(trips[1].weekIndex, 1);
      expect(trips[2].weekIndex, 2);
    });

    test("TripItem.freezeOnArrival defaults to false in non-freezing mode", () {
      Ingredient banana = _ingredient(id: "banana", products: [_product(shelfLifeDaysClosed: 5, canBeFrozen: true)]);
      Map<String, List<CookingEvent>> timeline = {
        "banana": [_event(day: 2, amount: 200)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [banana],
      );

      expect(trips.first.items.first.freezeOnArrival, isFalse);
    });
  });

  group("planShoppingTrips with assumeFreezerForFreezable: true", () {
    test("freezable perishable ingredient rides trip 0 with freezeOnArrival flag", () {
      // Chicken with 3-day closed shelf life used on day 14 (week 3).
      // Without freezing this would force trip 2; with freezing it rides trip 0.
      Ingredient chicken = _ingredient(id: "chicken", products: [_product(shelfLifeDaysClosed: 3, canBeFrozen: true)]);
      Map<String, List<CookingEvent>> timeline = {
        "chicken": [_event(day: 14, amount: 200)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [chicken],
        assumeFreezerForFreezable: true,
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 0);
      expect(trips.first.items.first.freezeOnArrival, isTrue);
    });

    test("non-freezable perishable still forces a later trip when shelf life exceeded", () {
      // Banana, 5-day shelf life, NOT freezable, used day 14. Must go on trip 2.
      Ingredient banana = _ingredient(id: "banana", products: [_product(shelfLifeDaysClosed: 5)]);
      Map<String, List<CookingEvent>> timeline = {
        "banana": [_event(day: 14, amount: 200)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [banana],
        assumeFreezerForFreezable: true,
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 2);
      expect(trips.first.items.first.freezeOnArrival, isFalse);
    });

    test("mixed freezable + non-freezable: freezable on trip 0 (frozen), non-freezable on later trip", () {
      Ingredient chicken = _ingredient(id: "chicken", products: [_product(shelfLifeDaysClosed: 3, canBeFrozen: true)]);
      Ingredient banana = _ingredient(id: "banana", products: [_product(shelfLifeDaysClosed: 5)]);
      Map<String, List<CookingEvent>> timeline = {
        "chicken": [_event(day: 14, amount: 200)],
        "banana": [_event(day: 14, amount: 200)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [chicken, banana],
        assumeFreezerForFreezable: true,
      );

      expect(trips.length, 2);
      ShoppingTrip trip0 = trips.firstWhere((t) => t.weekIndex == 0);
      ShoppingTrip later = trips.firstWhere((t) => t.weekIndex > 0);
      expect(trip0.items.length, 1);
      expect(trip0.items.first.ingredientId, "chicken");
      expect(trip0.items.first.freezeOnArrival, isTrue);
      expect(later.items.length, 1);
      expect(later.items.first.ingredientId, "banana");
      expect(later.items.first.freezeOnArrival, isFalse);
    });

    test("freezable item used within shelf life from trip 0 does not need freezing flag", () {
      // Chicken on day 1, shelf life 3 days. Trip 0 (day -1) → 2 days elapsed → fresh.
      // No freezing actually needed; the planner should NOT mark freezeOnArrival.
      Ingredient chicken = _ingredient(id: "chicken", products: [_product(shelfLifeDaysClosed: 3, canBeFrozen: true)]);
      Map<String, List<CookingEvent>> timeline = {
        "chicken": [_event(day: 1, amount: 200)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [chicken],
        assumeFreezerForFreezable: true,
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 0);
      expect(trips.first.items.first.freezeOnArrival, isFalse);
    });

    test("freezable non-perishable (null shelf life) is not flagged for freezing", () {
      // Long-shelf-life dry pasta marked canBeFrozen=true should not get the freeze flag
      // since it does not need freezing to last.
      Ingredient pasta = _ingredient(id: "pasta", products: [_product(canBeFrozen: true)]);
      Map<String, List<CookingEvent>> timeline = {
        "pasta": [_event(day: 14, amount: 500)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [pasta],
        assumeFreezerForFreezable: true,
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 0);
      expect(trips.first.items.first.freezeOnArrival, isFalse);
    });

    test("two freezable events in distant weeks both ride trip 0 with freeze flag", () {
      // Same ingredient on day 2 (within shelf life from trip 0) and day 14 (would expire).
      // Both should aggregate on trip 0; the aggregated item is freeze-on-arrival because
      // at least one underlying event needs freezing.
      Ingredient chicken = _ingredient(id: "chicken", products: [_product(shelfLifeDaysClosed: 3, canBeFrozen: true)]);
      Map<String, List<CookingEvent>> timeline = {
        "chicken": [_event(day: 2, amount: 100), _event(day: 14, amount: 200)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [chicken],
        assumeFreezerForFreezable: true,
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 0);
      expect(trips.first.items.first.amount, 300);
      expect(trips.first.items.first.freezeOnArrival, isTrue);
    });

    test("owned amount reduces freezable event amount before trip planning", () {
      Ingredient chicken = _ingredient(id: "chicken", products: [_product(shelfLifeDaysClosed: 3, canBeFrozen: true)]);
      Map<String, List<CookingEvent>> timeline = {
        "chicken": [_event(day: 14, amount: 200)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [chicken],
        assumeFreezerForFreezable: true,
        ownedAmounts: const {
          "chicken": [Quantity(amount: 50, unit: Unit.grams)],
        },
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 0);
      expect(trips.first.items.first.amount, 150);
      expect(trips.first.items.first.freezeOnArrival, isTrue);
    });

    test("owned amount fully covering a freezable event produces no trips", () {
      Ingredient chicken = _ingredient(id: "chicken", products: [_product(shelfLifeDaysClosed: 3, canBeFrozen: true)]);
      Map<String, List<CookingEvent>> timeline = {
        "chicken": [_event(day: 14, amount: 200)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [chicken],
        assumeFreezerForFreezable: true,
        ownedAmounts: const {
          "chicken": [Quantity(amount: 200, unit: Unit.grams)],
        },
      );

      expect(trips, isEmpty);
    });
  });

  group("planShoppingTrips multi-variant same-unit any-match semantics", () {
    test("uses the longest sealed shelf life across same-unit variants to consolidate trips", () {
      // Two grams variants: 2-day and 30-day. Two events on day 0 and day 14.
      // First-match (2-day) would force two separate trips (one per event window).
      // Any-match (30-day) lets a single trip cover both events.
      Ingredient ingredient = _ingredient(
        id: "i1",
        products: [
          _product(shelfLifeDaysClosed: 2),
          _product(shelfLifeDaysClosed: 30),
        ],
      );
      Map<String, List<CookingEvent>> timeline = {
        "i1": [_event(day: 0, amount: 100), _event(day: 14, amount: 100)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [ingredient],
      );

      expect(trips.length, 1);
    });

    test("treats ingredient as non-perishable when any same-unit variant has null shelf life", () {
      // One grams variant has shelfLifeDaysClosed=2, another has null (indefinite when sealed).
      // Planner should treat as non-perishable and ride trip 0 for any event day.
      Ingredient ingredient = _ingredient(
        id: "i1",
        products: [
          _product(shelfLifeDaysClosed: 2),
          _product(),
        ],
      );
      Map<String, List<CookingEvent>> timeline = {
        "i1": [_event(day: 14, amount: 100)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [ingredient],
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 0);
    });

    test("treats ingredient as freezable when any same-unit variant is freezable", () {
      // [non-freezable, freezable] same-unit variants. With freezer mode on, an event
      // on day 14 should ride trip 0 with freezeOnArrival=true.
      Ingredient ingredient = _ingredient(
        id: "i1",
        products: [
          _product(shelfLifeDaysClosed: 3),
          _product(shelfLifeDaysClosed: 3, canBeFrozen: true),
        ],
      );
      Map<String, List<CookingEvent>> timeline = {
        "i1": [_event(day: 14, amount: 100)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [ingredient],
        assumeFreezerForFreezable: true,
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, 0);
      expect(trips.first.items.first.freezeOnArrival, isTrue);
    });

    test("not freezable when no same-unit variant has canBeFrozen", () {
      // Both variants have canBeFrozen=false. Even with freezer mode on, planner forces a later trip.
      Ingredient ingredient = _ingredient(
        id: "i1",
        products: [
          _product(shelfLifeDaysClosed: 3),
          _product(shelfLifeDaysClosed: 5),
        ],
      );
      Map<String, List<CookingEvent>> timeline = {
        "i1": [_event(day: 14, amount: 100)],
      };

      List<ShoppingTrip> trips = planShoppingTrips(
        cookingTimeline: timeline,
        ingredients: [ingredient],
        assumeFreezerForFreezable: true,
      );

      expect(trips.length, 1);
      expect(trips.first.weekIndex, greaterThan(0));
      expect(trips.first.items.first.freezeOnArrival, isFalse);
    });
  });
}
