import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/cooking_timeline.dart";
import "package:menu_management/shopping/waste_optimizer.dart";

Product _product({double quantityPerItem = 250, int itemsPerPack = 1, Unit unit = Unit.grams, int? shelfLifeDays}) {
  return Product(
    link: "https://example.com",
    quantityPerItem: quantityPerItem,
    itemsPerPack: itemsPerPack,
    unit: unit,
    shelfLifeDaysOpened: shelfLifeDays,
  );
}

Ingredient _ingredient({double? density}) {
  return Ingredient(id: "test", name: "Test Ingredient", density: density);
}

/// Creates a single cooking event on the given day with the given amount.
CookingEvent _event({int day = 0, double amount = 100, Unit unit = Unit.grams}) {
  return CookingEvent(
    dayIndex: day,
    quantities: [Quantity(amount: amount, unit: unit)],
  );
}

void main() {
  group("rankProducts", () {
    group("over-buy waste only (no shelf life)", () {
      test("recommends product with least over-buy waste", () {
        // Need 500g. Small: 6x100g=600g (100g waste). Big: 1x1000g (500g waste).
        Product small = _product(quantityPerItem: 100, itemsPerPack: 6);
        Product big = _product(quantityPerItem: 1000);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 500,
          events: [_event(amount: 500)],
          ingredient: _ingredient(),
          products: [big, small],
        );

        expect(result.first.product, small);
        expect(result.first.packsNeeded, 1);
        expect(result.first.overBuyWaste, closeTo(100, 0.01));
        expect(result.first.totalWaste, closeTo(100, 0.01));
      });

      test("recommends exact-fit product with zero waste", () {
        Product exact = _product(quantityPerItem: 500);
        Product oversized = _product(quantityPerItem: 750);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 500,
          events: [_event(amount: 500)],
          ingredient: _ingredient(),
          products: [oversized, exact],
        );

        expect(result.first.product, exact);
        expect(result.first.totalWaste, closeTo(0, 0.01));
      });

      test("handles multiple packs needed", () {
        // Need 1200g. Product: 1x500g -> 3 packs = 1500g, 300g waste
        Product product = _product(quantityPerItem: 500);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 1200,
          events: [_event(amount: 1200)],
          ingredient: _ingredient(),
          products: [product],
        );

        expect(result.first.packsNeeded, 3);
        expect(result.first.overBuyWaste, closeTo(300, 0.01));
      });
    });

    group("event-based expiry simulation", () {
      test("single cooking event consuming all at once: no expiry waste", () {
        // Tomate Triturado scenario: need 900g in one cooking event.
        // 400g pack, 5-day shelf life. Opens 3 packs on cooking day.
        // Leftover 300g is over-buy, NOT expiry.
        Product product = _product(quantityPerItem: 400, shelfLifeDays: 5);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 900,
          events: [_event(amount: 900)],
          ingredient: _ingredient(),
          products: [product],
        );

        expect(result.first.packsNeeded, 3);
        expect(result.first.overBuyWaste, closeTo(300, 0.01));
        expect(result.first.expiryWaste, closeTo(0, 0.01));
        expect(result.first.isViable, isTrue);
      });

      test("two events within shelf life: no expiry waste", () {
        // Event 1: day 0, 200g. Event 2: day 3, 100g. Pack 400g, shelf life 5 days.
        // Day 0: open pack, use 200g, 200g remains.
        // Day 3: 3 days < 5 shelf life, pack still good. Use 100g, 100g remains.
        // Over-buy: 100g. Expiry: 0.
        Product product = _product(quantityPerItem: 400, shelfLifeDays: 5);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 300,
          events: [_event(day: 0, amount: 200), _event(day: 3, amount: 100)],
          ingredient: _ingredient(),
          products: [product],
        );

        expect(result.first.packsNeeded, 1);
        expect(result.first.overBuyWaste, closeTo(100, 0.01));
        expect(result.first.expiryWaste, closeTo(0, 0.01));
        expect(result.first.isViable, isTrue);
      });

      test("two events beyond shelf life: leftover expires", () {
        // Event 1: day 0, 200g. Event 2: day 10, 100g. Pack 400g, shelf life 5 days.
        // Day 0: open pack, use 200g, 200g remains.
        // Day 10: 10 > 5, the 200g expired! Open new pack, use 100g, 300g remains.
        // Over-buy: 300g. Expiry: 200g.
        Product product = _product(quantityPerItem: 400, shelfLifeDays: 5);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 300,
          events: [_event(day: 0, amount: 200), _event(day: 10, amount: 100)],
          ingredient: _ingredient(),
          products: [product],
        );

        expect(result.first.packsNeeded, 2);
        expect(result.first.overBuyWaste, closeTo(300, 0.01));
        expect(result.first.expiryWaste, closeTo(200, 0.01));
        expect(result.first.isViable, isFalse);
      });

      test("leftover from first event fully consumed in second event", () {
        // Event 1: day 0, 300g. Event 2: day 2, 150g. Pack 400g, shelf life 5 days.
        // Day 0: open pack, use 300g, 100g remains.
        // Day 2: 2 < 5, pack still good. Use 100g from pack, need 50g more.
        //         Open pack 2, use 50g, 350g remains.
        // Over-buy: 350g. Expiry: 0.
        Product product = _product(quantityPerItem: 400, shelfLifeDays: 5);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 450,
          events: [_event(day: 0, amount: 300), _event(day: 2, amount: 150)],
          ingredient: _ingredient(),
          products: [product],
        );

        expect(result.first.packsNeeded, 2);
        expect(result.first.overBuyWaste, closeTo(350, 0.01));
        expect(result.first.expiryWaste, closeTo(0, 0.01));
        expect(result.first.isViable, isTrue);
      });

      test("no expiry waste when shelfLifeDays is null (non-perishable)", () {
        Product product = _product(quantityPerItem: 500);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 500,
          events: [_event(day: 0, amount: 250), _event(day: 30, amount: 250)],
          ingredient: _ingredient(),
          products: [product],
        );

        expect(result.first.expiryWaste, closeTo(0, 0.01));
        expect(result.first.isViable, isTrue);
      });

      test("event exactly at shelf life boundary: no expiry", () {
        // Event 1: day 0, 200g. Event 2: day 5, 100g. Pack 400g, shelf life 5 days.
        // Day 5: gap == 5, NOT > 5, so no expiry.
        Product product = _product(quantityPerItem: 400, shelfLifeDays: 5);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 300,
          events: [_event(day: 0, amount: 200), _event(day: 5, amount: 100)],
          ingredient: _ingredient(),
          products: [product],
        );

        expect(result.first.expiryWaste, closeTo(0, 0.01));
        expect(result.first.isViable, isTrue);
      });
    });

    group("multi-item packs", () {
      test("sealed items consumed within shelf life: no expiry", () {
        // 6x125g yogurt cups, shelfLifeDays=5. Need 700g in one event.
        // Opens 6 items (all in one go), uses 700g, 50g remains in last item.
        // Over-buy: 50g. Expiry: 0.
        Product product = _product(quantityPerItem: 125, itemsPerPack: 6, shelfLifeDays: 5);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 700,
          events: [_event(amount: 700)],
          ingredient: _ingredient(),
          products: [product],
        );

        expect(result.first.packsNeeded, 1);
        expect(result.first.expiryWaste, closeTo(0, 0.01));
        expect(result.first.isViable, isTrue);
        expect(result.first.overBuyWaste, closeTo(50, 0.01));
      });

      test("multi-item pack with gap causing item expiry", () {
        // 4x200g items, shelf life 3 days. Two events: day 0 (150g), day 10 (150g).
        // Day 0: open item 1 (200g), use 150g, 50g remains.
        // Day 10: gap 10 > 3, 50g expires. Open item 2 (200g), use 150g, 50g remains.
        // containersOpened=2, packsNeeded=ceil(2/4)=1, unusedItems=2.
        // Over-buy: 50 + 2*200 = 450g. Expiry: 50g.
        Product product = _product(quantityPerItem: 200, itemsPerPack: 4, shelfLifeDays: 3);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 300,
          events: [_event(day: 0, amount: 150), _event(day: 10, amount: 150)],
          ingredient: _ingredient(),
          products: [product],
        );

        expect(result.first.packsNeeded, 1);
        expect(result.first.expiryWaste, closeTo(50, 0.01));
        expect(result.first.overBuyWaste, closeTo(450, 0.01));
        expect(result.first.isViable, isFalse);
      });

      test("prefers multi-item over single container when items avoid expiry", () {
        // 1x500g bucket (shelf life 3, single container) vs 6x125g cups (shelf life 3, sealed items).
        // Two events: day 0 (200g), day 1 (200g). Need 400g total.
        //
        // Bucket: day 0 open 500g, use 200g, 300g remains. Day 1: gap 1 < 3, use 200g, 100g remains.
        //   Over-buy: 100g. Expiry: 0. Total: 100g.
        //
        // Cups: day 0 open item1 (125g use all), open item2 (125g use 75g, 50g remains). Day 1: gap 1 < 3, use 50g from item2, open item3 use 125g, open item4 use 25g, 100g remains.
        //   containersOpened=4, packs=ceil(4/6)=1, unusedItems=2. Over-buy: 100+250=350g. Expiry: 0. Total: 350g.
        //
        // Bucket wins (100 < 350).
        Product bucket = _product(quantityPerItem: 500, itemsPerPack: 1, shelfLifeDays: 3);
        Product cups = _product(quantityPerItem: 125, itemsPerPack: 6, shelfLifeDays: 3);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 400,
          events: [_event(day: 0, amount: 200), _event(day: 1, amount: 200)],
          ingredient: _ingredient(),
          products: [bucket, cups],
        );

        expect(result.first.product, bucket);
      });
    });

    group("unit conversion in simulation", () {
      test("converts centiliters to grams via density", () {
        // Event in centiliters, product in grams. Density 1.07.
        // 2.25 cL = 22.5 mL * 1.07 = 24.075g. Need 24.075g from a 400g pack.
        Product product = _product(quantityPerItem: 400, unit: Unit.grams, shelfLifeDays: 5);
        Ingredient ingredient = Ingredient(id: "tomato", name: "Tomate", density: 1.07);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 24.075,
          events: [
            CookingEvent(dayIndex: 0, quantities: [const Quantity(amount: 2.25, unit: Unit.centiliters)]),
          ],
          ingredient: ingredient,
          products: [product],
        );

        expect(result.first.packsNeeded, 1);
        expect(result.first.overBuyWaste, closeTo(375.925, 0.1));
        expect(result.first.expiryWaste, closeTo(0, 0.01));
      });

      test("skips events with unconvertible units", () {
        // Event in pieces, product in grams, no gramsPerPiece defined.
        // Event amount should be 0 for this product, falling back to simple calc.
        Product product = _product(quantityPerItem: 400, unit: Unit.grams, shelfLifeDays: 5);
        Ingredient ingredient = Ingredient(id: "test", name: "Test");

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 100,
          events: [
            CookingEvent(dayIndex: 0, quantities: [const Quantity(amount: 5, unit: Unit.pieces)]),
          ],
          ingredient: ingredient,
          products: [product],
        );

        // Falls back to simple calculation since no events match the unit
        expect(result.first.packsNeeded, 1);
        expect(result.first.overBuyWaste, closeTo(300, 0.01));
        expect(result.first.expiryWaste, closeTo(0, 0.01));
      });
    });

    group("edge cases", () {
      test("returns empty list for empty products", () {
        List<ProductRecommendation> result = rankProducts(totalNeeded: 500, events: [_event(amount: 500)], ingredient: _ingredient(), products: []);
        expect(result, isEmpty);
      });

      test("handles empty events list", () {
        Product product = _product(quantityPerItem: 500, shelfLifeDays: 3);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 500, events: [], ingredient: _ingredient(), products: [product]);

        expect(result.length, 1);
        expect(result.first.packsNeeded, 1);
        expect(result.first.expiryWaste, closeTo(0, 0.01));
      });

      test("handles zero totalNeeded", () {
        Product product = _product(quantityPerItem: 500);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 0, events: [], ingredient: _ingredient(), products: [product]);

        expect(result.first.packsNeeded, 0);
        expect(result.first.totalWaste, closeTo(0, 0.01));
      });

      test("single product returns that product", () {
        Product only = _product(quantityPerItem: 300);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 500,
          events: [_event(amount: 500)],
          ingredient: _ingredient(),
          products: [only],
        );

        expect(result.length, 1);
        expect(result.first.product, only);
        expect(result.first.packsNeeded, 2);
      });

      test("three events with mixed expiry patterns", () {
        // Events: day 0 (100g), day 3 (100g), day 15 (100g). Pack 200g, shelf 5 days.
        // Day 0: open pack, use 100g, 100g remains.
        // Day 3: 3 < 5, pack good. Use 100g, 0g remains.
        // Day 15: open new pack, use 100g, 100g remains.
        // Over-buy: 100g. Expiry: 0.
        Product product = _product(quantityPerItem: 200, shelfLifeDays: 5);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 300,
          events: [_event(day: 0, amount: 100), _event(day: 3, amount: 100), _event(day: 15, amount: 100)],
          ingredient: _ingredient(),
          products: [product],
        );

        expect(result.first.packsNeeded, 2);
        expect(result.first.overBuyWaste, closeTo(100, 0.01));
        expect(result.first.expiryWaste, closeTo(0, 0.01));
        expect(result.first.isViable, isTrue);
      });

      test("expiry between second and third event", () {
        // Events: day 0 (100g), day 3 (50g), day 15 (100g). Pack 200g, shelf 5 days.
        // Day 0: open pack, use 100g, 100g remains.
        // Day 3: 3 < 5, pack good. Use 50g, 50g remains.
        // Day 15: 15-3=12 > 5, 50g expires! Open new pack, use 100g, 100g remains.
        // Over-buy: 100g. Expiry: 50g.
        Product product = _product(quantityPerItem: 200, shelfLifeDays: 5);

        List<ProductRecommendation> result = rankProducts(
          totalNeeded: 250,
          events: [_event(day: 0, amount: 100), _event(day: 3, amount: 50), _event(day: 15, amount: 100)],
          ingredient: _ingredient(),
          products: [product],
        );

        expect(result.first.packsNeeded, 2);
        expect(result.first.overBuyWaste, closeTo(100, 0.01));
        expect(result.first.expiryWaste, closeTo(50, 0.01));
        expect(result.first.isViable, isFalse);
      });
    });
  });

  group("recommendCombination", () {
    /// Returns a {packSize: packs} map so assertions do not depend on selection ordering.
    Map<double, int> packsBySize(CombinationRecommendation rec) {
      return {for (PackSelection s in rec.selections) s.product.totalQuantityPerPack: s.packs};
    }

    test("recommends a mix of two products when it beats every single product (per-event)", () {
      // Two cooking events beyond shelf life, so no food carries from the first to the second.
      // Day 0 needs 250 g, day 20 needs 600 g. Both products last 5 days once opened.
      //   Small 250 g pack: perfect for day 0, but day 20 needs 3 packs (750 g -> 150 g surplus).
      //   Large 600 g pack: perfect for day 20, but on day 0 it opens and 350 g expires by day 20.
      // Best combination: 1 small (day 0) + 1 large (day 20) = 850 g bought for 850 g needed, zero waste.
      Product small = _product(quantityPerItem: 250, shelfLifeDays: 5);
      Product large = _product(quantityPerItem: 600, shelfLifeDays: 5);

      CombinationRecommendation? rec = recommendCombination(
        totalNeeded: 850,
        events: [_event(day: 0, amount: 250), _event(day: 20, amount: 600)],
        ingredient: _ingredient(),
        products: [small, large],
      );

      expect(rec, isNotNull);
      expect(rec!.selections.length, 2);
      expect(packsBySize(rec), {250.0: 1, 600.0: 1});
      expect(rec.overBuyWaste, closeTo(0, 0.01));
      expect(rec.expiryWaste, closeTo(0, 0.01));
      expect(rec.totalWaste, closeTo(0, 0.01));
      expect(rec.isSingleProduct, isFalse);
    });

    test("combination accounts for individual cooking events, not only the weekly total", () {
      // Same 600 g total need, but split across two events 20 days apart (beyond 5-day shelf life).
      Product small = _product(quantityPerItem: 300, shelfLifeDays: 5);
      Product large = _product(quantityPerItem: 600, shelfLifeDays: 5);

      // Per-event: two 300 g events. A single 600 g pack opened on day 0 loses 300 g by day 20,
      // so the solver buys 2 small packs (300 g each), one per event -> zero waste.
      CombinationRecommendation? perEvent = recommendCombination(
        totalNeeded: 600,
        events: [_event(day: 0, amount: 300), _event(day: 20, amount: 300)],
        ingredient: _ingredient(),
        products: [small, large],
      );
      expect(perEvent, isNotNull);
      expect(packsBySize(perEvent!), {300.0: 2});
      expect(perEvent.totalWaste, closeTo(0, 0.01));

      // Weekly total only: a single 600 g event. Here the large pack is a perfect fit,
      // so the solver picks 1 large pack. Different answer -> the solver used the per-event split.
      CombinationRecommendation? lumped = recommendCombination(
        totalNeeded: 600,
        events: [_event(day: 0, amount: 600)],
        ingredient: _ingredient(),
        products: [small, large],
      );
      expect(lumped, isNotNull);
      expect(packsBySize(lumped!), {600.0: 1});
    });

    test("falls back to a single product when one product covers the need with least waste", () {
      // Need 500 g in one event. The 500 g pack is an exact fit (zero waste); no mix can beat it.
      Product exact = _product(quantityPerItem: 500);
      Product small = _product(quantityPerItem: 300);

      CombinationRecommendation? rec = recommendCombination(
        totalNeeded: 500,
        events: [_event(amount: 500)],
        ingredient: _ingredient(),
        products: [exact, small],
      );

      expect(rec, isNotNull);
      expect(rec!.isSingleProduct, isTrue);
      expect(packsBySize(rec), {500.0: 1});
      expect(rec.totalWaste, closeTo(0, 0.01));
    });

    test("prefers a single product over an equal-waste mix", () {
      // Need 750 g in one event. A single 750 g pack is an exact fit (zero waste).
      // A 250 g + 500 g mix is also an exact fit (zero waste), but a single product is simpler,
      // so the tie-break must pick the single 750 g pack.
      Product big = _product(quantityPerItem: 750);
      Product mid = _product(quantityPerItem: 500);
      Product small = _product(quantityPerItem: 250);

      CombinationRecommendation? rec = recommendCombination(
        totalNeeded: 750,
        events: [_event(amount: 750)],
        ingredient: _ingredient(),
        products: [big, mid, small],
      );

      expect(rec, isNotNull);
      expect(rec!.isSingleProduct, isTrue);
      expect(packsBySize(rec), {750.0: 1});
      expect(rec.totalWaste, closeTo(0, 0.01));
    });

    test("is deterministic: repeated calls give identical results", () {
      Product small = _product(quantityPerItem: 250, shelfLifeDays: 5);
      Product large = _product(quantityPerItem: 600, shelfLifeDays: 5);
      List<CookingEvent> events = [_event(day: 0, amount: 250), _event(day: 20, amount: 600)];

      CombinationRecommendation? first = recommendCombination(totalNeeded: 850, events: events, ingredient: _ingredient(), products: [small, large]);
      CombinationRecommendation? second = recommendCombination(totalNeeded: 850, events: events, ingredient: _ingredient(), products: [small, large]);

      expect(packsBySize(first!), packsBySize(second!));
      expect(first.overBuyWaste, closeTo(second.overBuyWaste, 0.0001));
      expect(first.expiryWaste, closeTo(second.expiryWaste, 0.0001));
    });

    test("is deterministic regardless of input product order", () {
      // Need 600 g in one event. Mix of 250 g + 400 g (650 g, 50 g surplus) beats both singles
      // (2x400 = 800 g -> 200 g surplus; 3x250 = 750 g -> 150 g surplus).
      Product a = _product(quantityPerItem: 400);
      Product b = _product(quantityPerItem: 250);

      CombinationRecommendation? forward = recommendCombination(
        totalNeeded: 600,
        events: [_event(amount: 600)],
        ingredient: _ingredient(),
        products: [a, b],
      );
      CombinationRecommendation? reversed = recommendCombination(
        totalNeeded: 600,
        events: [_event(amount: 600)],
        ingredient: _ingredient(),
        products: [b, a],
      );

      expect(packsBySize(forward!), {250.0: 1, 400.0: 1});
      expect(packsBySize(reversed!), packsBySize(forward));
      expect(forward.overBuyWaste, closeTo(50, 0.01));
      expect(reversed.overBuyWaste, closeTo(50, 0.01));
    });

    test("returns null for empty products", () {
      expect(recommendCombination(totalNeeded: 500, events: [_event(amount: 500)], ingredient: _ingredient(), products: []), isNull);
    });

    test("returns an empty, viable recommendation when nothing is needed", () {
      Product product = _product(quantityPerItem: 500);
      CombinationRecommendation? rec = recommendCombination(totalNeeded: 0, events: const [], ingredient: _ingredient(), products: [product]);

      expect(rec, isNotNull);
      expect(rec!.selections, isEmpty);
      expect(rec.totalWaste, closeTo(0, 0.01));
    });

    test("falls back to a single product when the search space exceeds the bound", () {
      // Tiny 1 g packs with a huge need blow past _maxCombinationVectors (20000): the 1 g product
      // alone needs 30000 packs, so the Cartesian product is far too large and the search is skipped.
      // The bounded fallback (_bestSingleAsCombination) returns the best single product instead.
      Product tiny = _product(quantityPerItem: 1);
      Product bigger = _product(quantityPerItem: 7);

      CombinationRecommendation? rec = recommendCombination(
        totalNeeded: 30000,
        events: const [],
        ingredient: _ingredient(),
        products: [tiny, bigger],
      );

      expect(rec, isNotNull);
      expect(rec!.selections, isNotEmpty);
      expect(rec.isSingleProduct, isTrue);
      // 30000 exact-fit 1 g packs (zero waste) beat 4286 x 7 g packs (2 g waste).
      expect(packsBySize(rec), {1.0: 30000});
      expect(rec.totalWaste, closeTo(0, 0.01));
    });

    test("a larger purchase wins when a quantity-sufficient one expires before a later event", () {
      // One 600 g pack, opened shelf life 3 days. Two events 300 g each, 10 days apart.
      // By raw quantity one 600 g pack covers the 600 g total, but it opens on day 0 and its 300 g
      // leftover expires before day 10, so a single pack cannot feed the second event: infeasible.
      // The solver must buy 2 packs. Bought 1200 g, consumed 600 g, 300 g expires, 300 g over-buy.
      Product pack = _product(quantityPerItem: 600, shelfLifeDays: 3);

      CombinationRecommendation? rec = recommendCombination(
        totalNeeded: 600,
        events: [_event(day: 0, amount: 300), _event(day: 10, amount: 300)],
        ingredient: _ingredient(),
        products: [pack],
      );

      expect(rec, isNotNull);
      expect(rec!.isSingleProduct, isTrue);
      expect(packsBySize(rec), {600.0: 2});
      expect(rec.expiryWaste, closeTo(300, 0.01));
      expect(rec.overBuyWaste, closeTo(300, 0.01));
      expect(rec.totalWaste, closeTo(600, 0.01));
    });
  });

  group("combinationPackLines", () {
    test("renders one pack line per selected product", () {
      Product small = _product(quantityPerItem: 250);
      Product large = _product(quantityPerItem: 600);
      CombinationRecommendation rec = CombinationRecommendation(
        selections: [
          PackSelection(product: small, packs: 1),
          PackSelection(product: large, packs: 2),
        ],
        overBuyWaste: 0,
        expiryWaste: 0,
      );

      expect(combinationPackLines(rec), ["250 grams/pack: 1 pack", "600 grams/pack: 2 packs"]);
    });

    test("uses the multi-item pack label when the product has one", () {
      Product cups = _product(quantityPerItem: 125, itemsPerPack: 6);
      CombinationRecommendation rec = CombinationRecommendation(
        selections: [PackSelection(product: cups, packs: 2)],
        overBuyWaste: 0,
        expiryWaste: 0,
      );

      expect(combinationPackLines(rec), ["6x125grams: 2 packs"]);
    });
  });

  group("combinationInlineSummary", () {
    test("joins the selected products into one line", () {
      Product small = _product(quantityPerItem: 250);
      Product large = _product(quantityPerItem: 600);
      CombinationRecommendation rec = CombinationRecommendation(
        selections: [
          PackSelection(product: small, packs: 1),
          PackSelection(product: large, packs: 1),
        ],
        overBuyWaste: 0,
        expiryWaste: 0,
      );

      expect(combinationInlineSummary(rec), "1x 250 grams/pack + 1x 600 grams/pack");
    });
  });
}
