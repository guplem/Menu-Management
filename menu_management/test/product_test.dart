import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";

Product _product({
  String link = "https://tienda.mercadona.es/product/test",
  int itemsPerPack = 1,
  double quantityPerItem = 250,
  Unit unit = Unit.grams,
}) {
  return Product(link: link, itemsPerPack: itemsPerPack, quantityPerItem: quantityPerItem, unit: unit);
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
        expect(product.formatQuantityForDisplay(200, Unit.grams), "1 packs (500 grams)");
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
    });
  });
}
