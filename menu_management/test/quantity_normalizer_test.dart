import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/quantity_normalizer.dart";

void main() {
  group("normalizeQuantities", () {
    group("same-family volume merging (no density needed)", () {
      test("merges tablespoons and centiliters into centiliters", () {
        // 12 tbsp = 18 cl, plus 400 cl = 418 cl
        Ingredient oil = const Ingredient(id: "oil", name: "Aceite de Girasol");
        List<Quantity> raw = const [Quantity(amount: 400, unit: Unit.centiliters), Quantity(amount: 12, unit: Unit.tablespoons)];

        List<Quantity> result = normalizeQuantities(ingredient: oil, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.centiliters);
        expect(result.first.amount, closeTo(418, 0.01));
      });

      test("merges teaspoons and tablespoons into centiliters", () {
        // 2 tbsp = 3 cl, 6 tsp = 3 cl => 6 cl
        Ingredient vinegar = const Ingredient(id: "v", name: "Vinagre");
        List<Quantity> raw = const [Quantity(amount: 2, unit: Unit.tablespoons), Quantity(amount: 6, unit: Unit.teaspoons)];

        List<Quantity> result = normalizeQuantities(ingredient: vinegar, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.centiliters);
        expect(result.first.amount, closeTo(6, 0.01));
      });

      test("single volume unit stays in centiliters after normalization", () {
        Ingredient oil = const Ingredient(id: "o", name: "Oil");
        List<Quantity> raw = const [Quantity(amount: 4, unit: Unit.tablespoons)];

        List<Quantity> result = normalizeQuantities(ingredient: oil, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.centiliters);
        expect(result.first.amount, closeTo(6, 0.01)); // 4 tbsp = 6 cl
      });
    });

    group("cross-family merging with density", () {
      test("volume-only with density but no product stays in centiliters", () {
        // Density should not force grams when there is no product to match against
        Ingredient yogurt = const Ingredient(id: "y", name: "Yogur Griego", density: 1.05);
        List<Quantity> raw = const [Quantity(amount: 72, unit: Unit.tablespoons)];

        List<Quantity> result = normalizeQuantities(ingredient: yogurt, rawQuantities: raw);

        // 72 tbsp * 15ml = 1080ml = 108cl
        expect(result.length, 1);
        expect(result.first.unit, Unit.centiliters);
        expect(result.first.amount, closeTo(108, 0.1));
      });

      test("merges grams and tablespoons into grams when density is known", () {
        // 500g + 3 tbsp (3*15*1.05 = 47.25g) = 547.25g
        Ingredient yogurt = const Ingredient(id: "y", name: "Yogur", density: 1.05);
        List<Quantity> raw = const [Quantity(amount: 500, unit: Unit.grams), Quantity(amount: 3, unit: Unit.tablespoons)];

        List<Quantity> result = normalizeQuantities(ingredient: yogurt, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.grams);
        expect(result.first.amount, closeTo(547.25, 0.1));
      });

      test("merges centiliters and grams into grams when density is known", () {
        // 10 cl = 100ml * 1.07 = 107g, plus 200g = 307g
        Ingredient tomato = const Ingredient(id: "t", name: "Tomate Triturado", density: 1.07);
        List<Quantity> raw = const [Quantity(amount: 200, unit: Unit.grams), Quantity(amount: 10, unit: Unit.centiliters)];

        List<Quantity> result = normalizeQuantities(ingredient: tomato, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.grams);
        expect(result.first.amount, closeTo(307, 0.1));
      });
    });

    group("no density, mixed families", () {
      test("keeps grams and tablespoons separate when density is null", () {
        Ingredient unknown = const Ingredient(id: "u", name: "Unknown");
        List<Quantity> raw = const [Quantity(amount: 200, unit: Unit.grams), Quantity(amount: 3, unit: Unit.tablespoons)];

        List<Quantity> result = normalizeQuantities(ingredient: unknown, rawQuantities: raw);

        expect(result.length, 2);
        expect(result.any((q) => q.unit == Unit.grams && q.amount == 200), isTrue);
        // tablespoons converted to centiliters even without density
        Quantity clQuantity = result.firstWhere((q) => q.unit == Unit.centiliters);
        expect(clQuantity.amount, closeTo(4.5, 0.01));
      });
    });

    group("pieces", () {
      test("pieces stay separate from grams", () {
        Ingredient egg = const Ingredient(id: "e", name: "Egg", density: 1.0);
        List<Quantity> raw = const [Quantity(amount: 6, unit: Unit.pieces), Quantity(amount: 100, unit: Unit.grams)];

        List<Quantity> result = normalizeQuantities(ingredient: egg, rawQuantities: raw);

        expect(result.length, 2);
        expect(result.any((q) => q.unit == Unit.pieces && q.amount == 6), isTrue);
        expect(result.any((q) => q.unit == Unit.grams && q.amount == 100), isTrue);
      });

      test("pieces alone pass through unchanged", () {
        Ingredient egg = const Ingredient(id: "e", name: "Egg");
        List<Quantity> raw = const [Quantity(amount: 12, unit: Unit.pieces)];

        List<Quantity> result = normalizeQuantities(ingredient: egg, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first, const Quantity(amount: 12, unit: Unit.pieces));
      });

      test("multiple pieces entries are summed", () {
        Ingredient egg = const Ingredient(id: "e", name: "Egg");
        List<Quantity> raw = const [Quantity(amount: 3, unit: Unit.pieces), Quantity(amount: 5, unit: Unit.pieces)];

        List<Quantity> result = normalizeQuantities(ingredient: egg, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.pieces);
        expect(result.first.amount, 8);
      });
    });

    group("single unit pass-through", () {
      test("single grams quantity passes through unchanged", () {
        Ingredient rice = const Ingredient(id: "r", name: "Rice");
        List<Quantity> raw = const [Quantity(amount: 500, unit: Unit.grams)];

        List<Quantity> result = normalizeQuantities(ingredient: rice, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first, const Quantity(amount: 500, unit: Unit.grams));
      });

      test("single centiliters quantity passes through unchanged", () {
        Ingredient milk = const Ingredient(id: "m", name: "Milk");
        List<Quantity> raw = const [Quantity(amount: 100, unit: Unit.centiliters)];

        List<Quantity> result = normalizeQuantities(ingredient: milk, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first, const Quantity(amount: 100, unit: Unit.centiliters));
      });
    });

    group("empty input", () {
      test("returns empty list for empty input", () {
        Ingredient any = const Ingredient(id: "a", name: "Any");
        List<Quantity> result = normalizeQuantities(ingredient: any, rawQuantities: const []);
        expect(result, isEmpty);
      });
    });

    group("pieces-to-grams conversion with gramsPerPiece", () {
      test("converts pieces to grams when gramsPerPiece is set and no pieces product exists", () {
        Ingredient garlic = Ingredient(
          id: "g",
          name: "Ajo troceado",
          gramsPerPiece: 5,
          products: [const Product(link: "https://example.com", quantityPerItem: 150, unit: Unit.grams)],
        );
        List<Quantity> raw = const [Quantity(amount: 3, unit: Unit.pieces)];

        List<Quantity> result = normalizeQuantities(ingredient: garlic, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.grams);
        expect(result.first.amount, closeTo(15, 0.1));
      });

      test("merges converted pieces with existing grams", () {
        Ingredient carrot = Ingredient(
          id: "c",
          name: "Zanahoria",
          gramsPerPiece: 80,
          products: [const Product(link: "https://example.com", quantityPerItem: 500, unit: Unit.grams)],
        );
        List<Quantity> raw = const [Quantity(amount: 2, unit: Unit.pieces), Quantity(amount: 100, unit: Unit.grams)];

        List<Quantity> result = normalizeQuantities(ingredient: carrot, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.grams);
        expect(result.first.amount, closeTo(260, 0.1)); // 2*80 + 100
      });

      test("keeps pieces when ingredient has a pieces product", () {
        Ingredient calabacin = Ingredient(
          id: "c",
          name: "Calabacin",
          gramsPerPiece: 410,
          products: [
            const Product(link: "https://example.com", quantityPerItem: 410, unit: Unit.grams),
            const Product(link: "https://example.com", quantityPerItem: 1, unit: Unit.pieces),
          ],
        );
        List<Quantity> raw = const [Quantity(amount: 2, unit: Unit.pieces)];

        List<Quantity> result = normalizeQuantities(ingredient: calabacin, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.pieces);
        expect(result.first.amount, 2);
      });

      test("keeps pieces when gramsPerPiece is null even with grams product", () {
        Ingredient garlic = Ingredient(
          id: "g",
          name: "Ajo troceado",
          products: [const Product(link: "https://example.com", quantityPerItem: 150, unit: Unit.grams)],
        );
        List<Quantity> raw = const [Quantity(amount: 3, unit: Unit.pieces)];

        List<Quantity> result = normalizeQuantities(ingredient: garlic, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.pieces);
        expect(result.first.amount, 3);
      });

      test("single pieces entry converts when gramsPerPiece is set and no pieces product", () {
        Ingredient garlic = Ingredient(
          id: "g",
          name: "Ajo troceado",
          gramsPerPiece: 5,
          products: [const Product(link: "https://example.com", quantityPerItem: 150, unit: Unit.grams)],
        );
        List<Quantity> raw = const [Quantity(amount: 4, unit: Unit.pieces)];

        List<Quantity> result = normalizeQuantities(ingredient: garlic, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.grams);
        expect(result.first.amount, closeTo(20, 0.1));
      });
    });

    group("target unit selection based on products", () {
      test("converts volume to grams when product is in grams and density is known", () {
        // Yogurt product is in grams, recipe uses tablespoons
        Ingredient yogurt = Ingredient(
          id: "y",
          name: "Yogur",
          density: 1.05,
          products: [const Product(link: "https://example.com", quantityPerItem: 125, unit: Unit.grams, itemsPerPack: 6)],
        );
        List<Quantity> raw = const [Quantity(amount: 10, unit: Unit.tablespoons)];

        List<Quantity> result = normalizeQuantities(ingredient: yogurt, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.grams);
        // 10 tbsp * 15ml * 1.05 = 157.5g
        expect(result.first.amount, closeTo(157.5, 0.1));
      });

      test("keeps centiliters when product is in centiliters", () {
        Ingredient oil = Ingredient(
          id: "o",
          name: "Oil",
          density: 0.91,
          products: [const Product(link: "https://example.com", quantityPerItem: 100, unit: Unit.centiliters)],
        );
        List<Quantity> raw = const [Quantity(amount: 6, unit: Unit.tablespoons)];

        List<Quantity> result = normalizeQuantities(ingredient: oil, rawQuantities: raw);

        expect(result.length, 1);
        expect(result.first.unit, Unit.centiliters);
        expect(result.first.amount, closeTo(9, 0.01)); // 6 tbsp = 9 cl
      });
    });
  });

  group("normalizeAllIngredients", () {
    test("normalizes a full ingredients map", () {
      Ingredient yogurt = const Ingredient(id: "y", name: "Yogur Griego", density: 1.05);
      Ingredient oil = const Ingredient(id: "o", name: "Oil");

      Map<String, List<Quantity>> raw = {
        "y": const [Quantity(amount: 72, unit: Unit.tablespoons)],
        "o": const [Quantity(amount: 400, unit: Unit.centiliters), Quantity(amount: 12, unit: Unit.tablespoons)],
      };
      List<Ingredient> ingredients = [yogurt, oil];

      Map<String, List<Quantity>> result = normalizeAllIngredients(rawQuantities: raw, ingredients: ingredients);

      // Yogurt: 72 tbsp -> centiliters (density known, but no product so no cross-family conversion)
      // 72 tbsp * 15ml = 1080ml = 108cl
      expect(result["y"]!.length, 1);
      expect(result["y"]!.first.unit, Unit.centiliters);
      expect(result["y"]!.first.amount, closeTo(108, 0.1));

      // Oil: 400cl + 12tbsp -> merged centiliters (no density, same family)
      expect(result["o"]!.length, 1);
      expect(result["o"]!.first.unit, Unit.centiliters);
      expect(result["o"]!.first.amount, closeTo(418, 0.01));
    });
  });
}
