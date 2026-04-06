import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/shopping/waste_optimizer.dart";

Product _product({
  double quantityPerItem = 250,
  int itemsPerPack = 1,
  Unit unit = Unit.grams,
  int? shelfLifeDays,
}) {
  return Product(link: "https://example.com", quantityPerItem: quantityPerItem, itemsPerPack: itemsPerPack, unit: unit, shelfLifeDays: shelfLifeDays);
}

void main() {
  group("rankProducts", () {
    group("over-buy waste only (no shelf life)", () {
      test("recommends product with least over-buy waste", () {
        // Need 500g. Small: 6x100g=600g (100g waste). Big: 1x1000g (500g waste).
        Product small = _product(quantityPerItem: 100, itemsPerPack: 6);
        Product big = _product(quantityPerItem: 1000);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 500, dailyUsage: 100, products: [big, small]);

        expect(result.first.product, small);
        expect(result.first.packsNeeded, 1);
        expect(result.first.overBuyWaste, closeTo(100, 0.01));
        expect(result.first.totalWaste, closeTo(100, 0.01));
      });

      test("recommends exact-fit product with zero waste", () {
        Product exact = _product(quantityPerItem: 500);
        Product oversized = _product(quantityPerItem: 750);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 500, dailyUsage: 100, products: [oversized, exact]);

        expect(result.first.product, exact);
        expect(result.first.totalWaste, closeTo(0, 0.01));
      });

      test("handles multiple packs needed", () {
        // Need 1200g. Product: 1x500g -> 3 packs = 1500g, 300g waste
        Product product = _product(quantityPerItem: 500);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 1200, dailyUsage: 200, products: [product]);

        expect(result.first.packsNeeded, 3);
        expect(result.first.overBuyWaste, closeTo(300, 0.01));
      });
    });

    group("expiry waste for single containers (itemsPerPack == 1)", () {
      test("flags waste when container expires before consumed", () {
        // Need 500g. Product: 1x500g, shelfLifeDays=3. Daily usage=100g.
        // Can consume 300g in 3 days, wastes 200g per pack.
        Product product = _product(quantityPerItem: 500, shelfLifeDays: 3);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 500, dailyUsage: 100, products: [product]);

        expect(result.first.expiryWaste, closeTo(200, 0.01));
        expect(result.first.isViable, isFalse);
      });

      test("no expiry waste when daily usage is high enough", () {
        // Need 500g. Product: 1x500g, shelfLifeDays=5. Daily usage=100g.
        // Can consume 500g in 5 days. No expiry waste.
        Product product = _product(quantityPerItem: 500, shelfLifeDays: 5);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 500, dailyUsage: 100, products: [product]);

        expect(result.first.expiryWaste, closeTo(0, 0.01));
        expect(result.first.isViable, isTrue);
      });

      test("no expiry waste when shelfLifeDays is null (non-perishable)", () {
        Product product = _product(quantityPerItem: 500);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 500, dailyUsage: 10, products: [product]);

        expect(result.first.expiryWaste, closeTo(0, 0.01));
        expect(result.first.isViable, isTrue);
      });
    });

    group("expiry waste for sealed-item packs (itemsPerPack > 1)", () {
      test("no expiry waste when individual items are consumed within shelf life", () {
        // 6x125g yogurt cups, shelfLifeDays=5. Daily usage=125g.
        // Each cup consumed in 1 day (< 5 days). No waste.
        Product product = _product(quantityPerItem: 125, itemsPerPack: 6, shelfLifeDays: 5);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 700, dailyUsage: 125, products: [product]);

        expect(result.first.expiryWaste, closeTo(0, 0.01));
        expect(result.first.isViable, isTrue);
      });

      test("flags waste when individual item takes too long to consume", () {
        // 1x500g bucket, shelfLifeDays=3, daily=100g. Takes 5 days to consume. Waste: 200g.
        // vs 6x125g cups, shelfLifeDays=3, daily=100g. Each cup takes 1.25 days. No waste.
        Product bucket = _product(quantityPerItem: 500, itemsPerPack: 1, shelfLifeDays: 3);
        Product cups = _product(quantityPerItem: 125, itemsPerPack: 6, shelfLifeDays: 3);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 700, dailyUsage: 100, products: [bucket, cups]);

        // Cups should be recommended (less waste)
        expect(result.first.product, cups);
        expect(result.first.isViable, isTrue);

        // Bucket has expiry waste
        ProductRecommendation bucketRec = result.firstWhere((r) => r.product == bucket);
        expect(bucketRec.isViable, isFalse);
        expect(bucketRec.expiryWaste, greaterThan(0));
      });
    });

    group("edge cases", () {
      test("returns empty list for empty products", () {
        List<ProductRecommendation> result = rankProducts(totalNeeded: 500, dailyUsage: 100, products: []);
        expect(result, isEmpty);
      });

      test("handles zero daily usage gracefully", () {
        Product product = _product(quantityPerItem: 500, shelfLifeDays: 3);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 500, dailyUsage: 0, products: [product]);

        expect(result.length, 1);
        expect(result.first.packsNeeded, 1);
      });

      test("handles zero totalNeeded", () {
        Product product = _product(quantityPerItem: 500);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 0, dailyUsage: 100, products: [product]);

        expect(result.first.packsNeeded, 0);
        expect(result.first.totalWaste, closeTo(0, 0.01));
      });

      test("single product returns that product", () {
        Product only = _product(quantityPerItem: 300);

        List<ProductRecommendation> result = rankProducts(totalNeeded: 500, dailyUsage: 100, products: [only]);

        expect(result.length, 1);
        expect(result.first.product, only);
        expect(result.first.packsNeeded, 2);
      });
    });
  });
}
