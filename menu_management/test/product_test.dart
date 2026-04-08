import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";

Product _product({
  String link = "https://tienda.mercadona.es/product/test",
  int itemsPerPack = 1,
  double quantityPerItem = 250,
  Unit unit = Unit.grams,
  int? shelfLifeDays,
}) {
  return Product(link: link, itemsPerPack: itemsPerPack, quantityPerItem: quantityPerItem, unit: unit, shelfLifeDays: shelfLifeDays);
}

void main() {
  // ── Product ──

  group("Product", () {
    group("totalQuantityPerPack", () {
      test("returns quantityPerItem when itemsPerPack is 1", () {
        Product product = _product(itemsPerPack: 1, quantityPerItem: 250);
        expect(product.totalQuantityPerPack, 250);
      });

      test("multiplies itemsPerPack by quantityPerItem", () {
        Product product = _product(itemsPerPack: 4, quantityPerItem: 100);
        expect(product.totalQuantityPerPack, 400);
      });
    });

    group("packsNeeded", () {
      test("returns 1 when required amount exactly matches one pack", () {
        Product product = _product(itemsPerPack: 4, quantityPerItem: 100);
        expect(product.packsNeeded(400), 1);
      });

      test("rounds up when required amount exceeds one pack", () {
        Product product = _product(itemsPerPack: 4, quantityPerItem: 100);
        expect(product.packsNeeded(401), 2);
      });

      test("returns 0 when required amount is zero", () {
        Product product = _product();
        expect(product.packsNeeded(0), 0);
      });

      test("returns 0 when required amount is negative", () {
        Product product = _product();
        expect(product.packsNeeded(-10), 0);
      });

      test("returns 1 when required amount is less than one pack", () {
        Product product = _product(itemsPerPack: 1, quantityPerItem: 500);
        expect(product.packsNeeded(200), 1);
      });

      test("handles large amounts correctly", () {
        Product product = _product(itemsPerPack: 6, quantityPerItem: 100);
        expect(product.packsNeeded(1800), 3);
        expect(product.packsNeeded(1801), 4);
      });
    });

    group("formatQuantityForDisplay", () {
      test("returns pack format when unit matches", () {
        Product product = _product(itemsPerPack: 4, quantityPerItem: 100, unit: Unit.grams);
        expect(product.formatQuantityForDisplay(500, Unit.grams), "2 packs (800 grams)");
      });

      test("returns raw amount when unit does not match", () {
        Product product = _product(unit: Unit.grams);
        expect(product.formatQuantityForDisplay(500, Unit.centiliters), "500 centiliters");
      });

      test("rounds raw amount to integer", () {
        Product product = _product(unit: Unit.grams);
        expect(product.formatQuantityForDisplay(333.7, Unit.centiliters), "334 centiliters");
      });

      test("returns 1 pack when amount is less than one pack and unit matches", () {
        Product product = _product(itemsPerPack: 1, quantityPerItem: 500, unit: Unit.grams);
        expect(product.formatQuantityForDisplay(200, Unit.grams), "1 pack (500 grams)");
      });
    });

    group("defaults", () {
      test("itemsPerPack defaults to 1", () {
        Product product = const Product(link: "https://example.com", quantityPerItem: 250, unit: Unit.grams);
        expect(product.itemsPerPack, 1);
      });
    });

    group("JSON serialization", () {
      test("round-trips through JSON", () {
        Product original = _product(itemsPerPack: 4, quantityPerItem: 100, unit: Unit.grams);
        String encoded = jsonEncode(original.toJson());
        Product restored = Product.fromJson(jsonDecode(encoded));
        expect(restored, original);
      });

      test("round-trips with centiliters unit", () {
        Product original = _product(unit: Unit.centiliters, quantityPerItem: 33);
        String encoded = jsonEncode(original.toJson());
        Product restored = Product.fromJson(jsonDecode(encoded));
        expect(restored.unit, Unit.centiliters);
        expect(restored.quantityPerItem, 33);
      });
    });
  });

  // ── Ingredient with Products ──

  group("Ingredient", () {
    group("products field", () {
      test("defaults to empty list when not provided", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Rice");
        expect(ingredient.products, isEmpty);
      });

      test("stores products when provided", () {
        Product product = _product();
        Ingredient ingredient = Ingredient(id: "i1", name: "Rice", products: [product]);
        expect(ingredient.products, [product]);
      });

      test("stores multiple products", () {
        Product small = _product(quantityPerItem: 100);
        Product large = _product(quantityPerItem: 500);
        Ingredient ingredient = Ingredient(id: "i1", name: "Rice", products: [small, large]);
        expect(ingredient.products.length, 2);
        expect(ingredient.products.first.quantityPerItem, 100);
        expect(ingredient.products.last.quantityPerItem, 500);
      });

      test("copyWith can add products", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Rice");
        Product product = _product();
        Ingredient updated = ingredient.copyWith(products: [product]);
        expect(updated.products, [product]);
        expect(updated.name, "Rice");
      });

      test("copyWith can clear products", () {
        Ingredient ingredient = Ingredient(id: "i1", name: "Rice", products: [_product()]);
        Ingredient updated = ingredient.copyWith(products: []);
        expect(updated.products, isEmpty);
      });
    });

    group("JSON serialization", () {
      test("round-trips without products (backward compatibility)", () {
        Ingredient original = const Ingredient(id: "i1", name: "Rice");
        String encoded = jsonEncode(original.toJson());
        Ingredient restored = Ingredient.fromJson(jsonDecode(encoded));
        expect(restored, original);
        expect(restored.products, isEmpty);
      });

      test("round-trips with single product", () {
        Product product = _product(itemsPerPack: 2, quantityPerItem: 500, unit: Unit.grams);
        Ingredient original = Ingredient(id: "i1", name: "Rice", products: [product]);
        String encoded = jsonEncode(original.toJson());
        Ingredient restored = Ingredient.fromJson(jsonDecode(encoded));
        expect(restored, original);
        expect(restored.products.first.itemsPerPack, 2);
        expect(restored.products.first.quantityPerItem, 500);
      });

      test("round-trips with multiple products", () {
        Product small = _product(quantityPerItem: 100);
        Product large = _product(quantityPerItem: 500);
        Ingredient original = Ingredient(id: "i1", name: "Rice", products: [small, large]);
        String encoded = jsonEncode(original.toJson());
        Ingredient restored = Ingredient.fromJson(jsonDecode(encoded));
        expect(restored, original);
        expect(restored.products.length, 2);
      });

      test("deserializes old JSON without products field", () {
        Map<String, dynamic> oldJson = {"id": "i1", "name": "Rice"};
        Ingredient restored = Ingredient.fromJson(oldJson);
        expect(restored.id, "i1");
        expect(restored.name, "Rice");
        expect(restored.products, isEmpty);
      });

      test("deserializes old JSON without density field", () {
        Map<String, dynamic> oldJson = {"id": "i1", "name": "Rice"};
        Ingredient restored = Ingredient.fromJson(oldJson);
        expect(restored.density, isNull);
      });

      test("round-trips with density", () {
        Ingredient original = const Ingredient(id: "i1", name: "Yogurt", density: 1.05);
        String encoded = jsonEncode(original.toJson());
        Ingredient restored = Ingredient.fromJson(jsonDecode(encoded));
        expect(restored.density, 1.05);
      });

      test("omits density from JSON when null", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Rice");
        Map<String, dynamic> json = ingredient.toJson();
        expect(json.containsKey("density"), isFalse);
      });
    });

    group("density field", () {
      test("defaults to null when not provided", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Rice");
        expect(ingredient.density, isNull);
      });

      test("stores density when provided", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Yogurt", density: 1.05);
        expect(ingredient.density, 1.05);
      });

      test("copyWith can set density", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Oil");
        Ingredient updated = ingredient.copyWith(density: 0.92);
        expect(updated.density, 0.92);
      });
    });

    group("toGrams", () {
      test("returns amount unchanged for grams", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Yogurt", density: 1.05);
        double? result = ingredient.toGrams(const Quantity(amount: 500, unit: Unit.grams));
        expect(result, 500);
      });

      test("converts centiliters to grams using density", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Yogurt", density: 1.05);
        // 10 cl = 100 ml, 100 ml * 1.05 g/ml = 105 g
        double? result = ingredient.toGrams(const Quantity(amount: 10, unit: Unit.centiliters));
        expect(result, 105);
      });

      test("converts tablespoons to grams using density", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Oil", density: 0.92);
        // 1 tbsp = 15 ml, 15 ml * 0.92 g/ml = 13.8 g
        double? result = ingredient.toGrams(const Quantity(amount: 1, unit: Unit.tablespoons));
        expect(result, closeTo(13.8, 0.001));
      });

      test("converts teaspoons to grams using density", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Salt", density: 2.16);
        // 1 tsp = 5 ml, 5 ml * 2.16 g/ml = 10.8 g
        double? result = ingredient.toGrams(const Quantity(amount: 1, unit: Unit.teaspoons));
        expect(result, closeTo(10.8, 0.001));
      });

      test("returns null for pieces", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Egg", density: 1.0);
        double? result = ingredient.toGrams(const Quantity(amount: 6, unit: Unit.pieces));
        expect(result, isNull);
      });

      test("returns null when density is null", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Rice");
        double? result = ingredient.toGrams(const Quantity(amount: 100, unit: Unit.centiliters));
        expect(result, isNull);
      });

      test("converts 72 tablespoons of yogurt correctly", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Yogur Griego", density: 1.05);
        // 72 tbsp = 72 * 15 ml = 1080 ml, 1080 * 1.05 = 1134 g
        double? result = ingredient.toGrams(const Quantity(amount: 72, unit: Unit.tablespoons));
        expect(result, closeTo(1134, 0.001));
      });
    });

    group("fromGrams", () {
      test("returns grams unchanged", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Yogurt", density: 1.05);
        double? result = ingredient.fromGrams(500, Unit.grams);
        expect(result, 500);
      });

      test("converts grams to centiliters using density", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Yogurt", density: 1.05);
        // 105 g / (10 ml/cl * 1.05 g/ml) = 10 cl
        double? result = ingredient.fromGrams(105, Unit.centiliters);
        expect(result, closeTo(10, 0.001));
      });

      test("converts grams to tablespoons using density", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Oil", density: 0.92);
        // 13.8 g / (15 ml/tbsp * 0.92 g/ml) = 1 tbsp
        double? result = ingredient.fromGrams(13.8, Unit.tablespoons);
        expect(result, closeTo(1, 0.001));
      });

      test("returns null for pieces", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Egg", density: 1.0);
        double? result = ingredient.fromGrams(500, Unit.pieces);
        expect(result, isNull);
      });

      test("returns null when density is null", () {
        Ingredient ingredient = const Ingredient(id: "i1", name: "Rice");
        double? result = ingredient.fromGrams(500, Unit.centiliters);
        expect(result, isNull);
      });
    });
  });

  // ── Product shelfLifeDays ──

  group("Product shelfLifeDays", () {
    test("defaults to null when not provided", () {
      Product product = _product();
      expect(product.shelfLifeDays, isNull);
    });

    test("stores shelfLifeDays when provided", () {
      Product product = _product(shelfLifeDays: 3);
      expect(product.shelfLifeDays, 3);
    });

    test("round-trips through JSON with shelfLifeDays", () {
      Product original = _product(shelfLifeDays: 5);
      String encoded = jsonEncode(original.toJson());
      Product restored = Product.fromJson(jsonDecode(encoded));
      expect(restored.shelfLifeDays, 5);
    });

    test("deserializes old JSON without shelfLifeDays", () {
      Map<String, dynamic> oldJson = {
        "link": "https://example.com",
        "quantityPerItem": 250.0,
        "unit": "grams",
      };
      Product restored = Product.fromJson(oldJson);
      expect(restored.shelfLifeDays, isNull);
    });

    test("omits shelfLifeDays from JSON when null", () {
      Product product = _product();
      Map<String, dynamic> json = product.toJson();
      expect(json.containsKey("shelfLifeDays"), isFalse);
    });
  });
}
