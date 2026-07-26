import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";
import "package:menu_management/shopping/owned_amount.dart";
import "package:menu_management/shopping/shopping_ingredient.dart";
import "package:menu_management/shopping/waste_optimizer.dart";

// 100 grams per pack (2 items x 50 grams), so itemsPerPack > 1 keeps the "pack(s)" wording.
Product _packProduct() => const Product(link: "", quantityPerItem: 50, itemsPerPack: 2, unit: Unit.grams);

Ingredient _ingredient() => Ingredient(id: "beans", name: "Beans", products: [_packProduct()]);

// 500 grams per pack (2 items x 250 grams), itemsPerPack > 1 keeps the "pack(s)" wording.
// Different links make these variety variants (e.g. pizza flavors) that share every buying trait.
Product _equivProduct(String link) => Product(link: link, quantityPerItem: 250, itemsPerPack: 2, unit: Unit.grams);

ProductRecommendation _rec(Product product, int packsNeeded) =>
    ProductRecommendation(product: product, packsNeeded: packsNeeded, overBuyWaste: 0, expiryWaste: 0, isViable: true);

/// Pumps a [ShoppingIngredient] with the given products, remaining amount, and recommendations,
/// capturing the value passed to `onOwnedChanged` (used by the auto-fill test).
///
/// [quantitiesDesired] defaults to a grams recipe that matches the grams products, so per-product
/// owned inputs render. The auto-fill tests override it with a unit the products do not use, so the
/// header owned input (which hosts the auto-fill button) renders instead (see [usesPerProductOwnedInputs]).
Future<void> _pumpProducts(
  WidgetTester tester, {
  required List<Product> products,
  required double remainingGrams,
  List<ProductRecommendation> recommendations = const [],
  OwnedUnit ownedUnit = const OwnedUnit(),
  List<Quantity> quantitiesDesired = const [Quantity(amount: 1500, unit: Unit.grams)],
  void Function(double amount, OwnedUnit unit)? onOwnedChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      // The flutter_test placeholder font renders every glyph as a fixed-width box wider than the real
      // font, which overflows the fixed-width unit dropdown when the header input renders. Shrink the
      // text scale so the layout has room; these tests verify logic, not pixel-exact widths.
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.7)),
        child: child!,
      ),
      home: Scaffold(
        body: ShoppingIngredient(
          ingredient: Ingredient(id: "pizza", name: "Pizza", products: products),
          quantitiesDesired: quantitiesDesired,
          calculatedRemainingQuantities: [Quantity(amount: remainingGrams, unit: Unit.grams)],
          productRecommendations: recommendations,
          ownedAmount: 0,
          ownedUnit: ownedUnit,
          onOwnedChanged: onOwnedChanged ?? (double amount, OwnedUnit unit) {},
          ownedProductCounts: const {},
          onProductOwnedChanged: (int productIndex, double count) {},
          sources: const [],
          plannedTrips: const [],
        ),
      ),
    ),
  );
}

ShoppingTrip _trip(int weekIndex, List<TripItem> items) => ShoppingTrip(weekIndex: weekIndex, items: items);

TripItem _item({String ingredientId = "beans", required double amount, bool freezeOnArrival = false}) =>
    TripItem(ingredientId: ingredientId, amount: amount, unit: Unit.grams, freezeOnArrival: freezeOnArrival);

/// Pumps [ShoppingIngredient] in isolation with real [plannedTrips], so the assertions
/// exercise `_tripPurchasesForProduct` (the split computation), not hand-built purchases.
Future<void> _pumpIngredient(
  WidgetTester tester, {
  required double remainingGrams,
  required List<ShoppingTrip> plannedTrips,
  List<CombinationRecommendation> combinationRecommendations = const [],
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ShoppingIngredient(
          ingredient: _ingredient(),
          quantitiesDesired: const [Quantity(amount: 900, unit: Unit.grams)],
          calculatedRemainingQuantities: [Quantity(amount: remainingGrams, unit: Unit.grams)],
          productRecommendations: const [],
          combinationRecommendations: combinationRecommendations,
          ownedAmount: 0,
          ownedUnit: const OwnedUnit(),
          onOwnedChanged: (double amount, OwnedUnit unit) {},
          ownedProductCounts: const {},
          onProductOwnedChanged: (int productIndex, double count) {},
          sources: const [],
          plannedTrips: plannedTrips,
        ),
      ),
    ),
  );
}

Future<void> _pumpForOwnedInputs(
  WidgetTester tester, {
  required Ingredient ingredient,
  required List<Quantity> quantitiesDesired,
  void Function(int productIndex, double count)? onProductOwnedChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ShoppingIngredient(
          ingredient: ingredient,
          quantitiesDesired: quantitiesDesired,
          calculatedRemainingQuantities: const [Quantity(amount: 100, unit: Unit.grams)],
          productRecommendations: const [],
          ownedAmount: 0,
          ownedUnit: const OwnedUnit(unit: Unit.grams),
          onOwnedChanged: (double amount, OwnedUnit unit) {},
          ownedProductCounts: const {},
          onProductOwnedChanged: onProductOwnedChanged ?? (int productIndex, double count) {},
          sources: const [],
          plannedTrips: const [],
        ),
      ),
    ),
  );
}

/// Stateful test harness that mirrors how `ShoppingPage` wires owned stock: it picks the owned
/// stock shape with [usesPerProductOwnedInputs] and recomputes the on-screen remaining ("Need")
/// through the shared [OwnedStock] resolver, so a change in the owned input flows to the "Need" text.
class _OwnedHarness extends StatefulWidget {
  const _OwnedHarness({required this.ingredient, required this.desired});

  final Ingredient ingredient;
  final List<Quantity> desired;

  @override
  State<_OwnedHarness> createState() => _OwnedHarnessState();
}

class _OwnedHarnessState extends State<_OwnedHarness> {
  double ownedAmount = 0;
  late OwnedUnit ownedUnit = defaultOwnedUnit(ingredient: widget.ingredient, desiredQuantities: widget.desired);
  final Map<int, double> ownedProductCounts = {};

  OwnedStock get _stock => usesPerProductOwnedInputs(ingredient: widget.ingredient, desiredQuantities: widget.desired)
      ? OwnedStock.perProduct(countsByProductIndex: ownedProductCounts)
      : OwnedStock(amount: ownedAmount, unit: ownedUnit.unit);

  List<Quantity> get _remaining => widget.desired
      .map(
        (Quantity q) => Quantity(
          amount: max(0.0, q.amount - _stock.amountInUnit(ingredient: widget.ingredient, targetUnit: q.unit)).roundToDouble(),
          unit: q.unit,
        ),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The flutter_test placeholder font renders every glyph as a fixed-width box, which is wider
      // than the real font and overflows the fixed-width unit dropdown. Shrink the text scale so the
      // layout has room; this test verifies owned-input logic, not pixel-exact widths.
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.7)),
        child: child!,
      ),
      home: Scaffold(
        body: ShoppingIngredient(
          ingredient: widget.ingredient,
          quantitiesDesired: widget.desired,
          calculatedRemainingQuantities: _remaining,
          productRecommendations: const [],
          ownedAmount: ownedAmount,
          ownedUnit: ownedUnit,
          onOwnedChanged: (double amount, OwnedUnit unit) => setState(() {
            ownedAmount = amount;
            ownedUnit = unit;
          }),
          ownedProductCounts: ownedProductCounts,
          onProductOwnedChanged: (int index, double count) => setState(() => ownedProductCounts[index] = count),
          sources: const [],
          plannedTrips: const [],
        ),
      ),
    );
  }
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

    testWidgets("an ingredient with products shows a per-product owned input, not the header input", (WidgetTester tester) async {
      double? reportedIndex;
      double? reportedCount;
      await _pumpForOwnedInputs(
        tester,
        ingredient: _ingredient(),
        quantitiesDesired: const [Quantity(amount: 900, unit: Unit.grams)],
        onProductOwnedChanged: (int productIndex, double count) {
          reportedIndex = productIndex.toDouble();
          reportedCount = count;
        },
      );

      // The per-product owned field lives in the product row.
      Finder ownedField = find.widgetWithText(TextField, "Owned");
      expect(ownedField, findsOneWidget);

      await tester.enterText(ownedField, "3");
      expect(reportedIndex, 0);
      expect(reportedCount, 3);
    });

    testWidgets("an ingredient with no products keeps the single header owned input", (WidgetTester tester) async {
      await _pumpForOwnedInputs(
        tester,
        ingredient: const Ingredient(id: "spice", name: "Spice"),
        quantitiesDesired: const [Quantity(amount: 5, unit: Unit.grams)],
      );

      // Header input is present; there are no product rows to host a per-product input.
      expect(find.widgetWithText(TextField, "Owned"), findsOneWidget);
    });

    testWidgets("shows the header owned input as a fallback when no product unit matches a recipe unit, and entering it reduces Need", (
      WidgetTester tester,
    ) async {
      // Egg-like ingredient: the only product is sold in pieces (6 per pack) with gramsPerPiece,
      // but the recipe needs grams. No product row matches the grams unit, so the per-product
      // inputs never render. The header owned input must appear so the user can still enter stock.
      // Wide desktop-like surface so the header row (owned input + unit dropdown) has room to lay out.
      await tester.binding.setSurfaceSize(const Size(1200, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Ingredient egg = Ingredient(
        id: "egg",
        name: "Egg",
        gramsPerPiece: 60,
        products: [const Product(link: "", quantityPerItem: 1, itemsPerPack: 6, unit: Unit.pieces)],
      );
      await tester.pumpWidget(
        _OwnedHarness(
          ingredient: egg,
          desired: const [Quantity(amount: 300, unit: Unit.grams)],
        ),
      );

      // The header owned input is present even though the product unit (pieces) does not match grams.
      expect(find.widgetWithText(TextField, "Owned"), findsOneWidget);
      expect(find.text("Need: 300 grams"), findsOneWidget);

      // Default owned unit is pieces (from the pieces product). Owning 2 eggs = 120 g via gramsPerPiece,
      // so the on-screen Need drops from 300 g to 180 g.
      await tester.enterText(find.widgetWithText(TextField, "Owned"), "2");
      await tester.pump();
      expect(find.text("Need: 180 grams"), findsOneWidget);
      expect(find.text("Need: 300 grams"), findsNothing);
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

  group("ShoppingIngredient best-value banner", () {
    // A real 2-product mix, so the "Best value" banner is shown.
    CombinationRecommendation buildMix() {
      const Product small = Product(link: "a", quantityPerItem: 250, itemsPerPack: 1, unit: Unit.grams);
      const Product large = Product(link: "b", quantityPerItem: 600, itemsPerPack: 1, unit: Unit.grams);
      return const CombinationRecommendation(
        selections: [
          PackSelection(product: small, packs: 1),
          PackSelection(product: large, packs: 1),
        ],
        overBuyWaste: 0,
        expiryWaste: 0,
      );
    }

    testWidgets("warns that the copied list splits per trip so it can differ from the banner", (WidgetTester tester) async {
      await _pumpIngredient(tester, remainingGrams: 850, plannedTrips: const [], combinationRecommendations: [buildMix()]);

      expect(find.text("Best value: "), findsNothing); // it is part of a RichText, not a standalone Text
      expect(find.textContaining("per shop trip"), findsOneWidget);
    });

    testWidgets("shows no per-trip note when there is no mix banner", (WidgetTester tester) async {
      await _pumpIngredient(tester, remainingGrams: 600, plannedTrips: const []);

      expect(find.textContaining("per shop trip"), findsNothing);
    });
  });

  group("ShoppingIngredient equivalent-product grouping", () {
    testWidgets("shows the cycled one-of-each share and joins equivalents with 'and'", (WidgetTester tester) async {
      // Three equivalent 500 g variants, need 1500 g -> 3 packs total -> 1 pack each.
      await _pumpProducts(tester, products: [_equivProduct("a"), _equivProduct("b"), _equivProduct("c")], remainingGrams: 1500);

      expect(find.text("Buy 1 pack"), findsNWidgets(3));
      // Each of the full-solo counts must NOT appear (the bug this fixes).
      expect(find.text("Buy 3 packs"), findsNothing);
      // Members of one equivalence group are combined, not mutually exclusive.
      expect(find.text("and"), findsNWidgets(2));
      expect(find.text("or"), findsNothing);
    });

    testWidgets("keeps 'or' alternatives and solo counts for non-equivalent products", (WidgetTester tester) async {
      // Different pack sizes -> not equivalent -> each shows its own full solo count, joined by "or".
      Product small = const Product(link: "small", quantityPerItem: 250, itemsPerPack: 2, unit: Unit.grams); // 500 g
      Product big = const Product(link: "big", quantityPerItem: 250, itemsPerPack: 3, unit: Unit.grams); // 750 g
      await _pumpProducts(tester, products: [small, big], remainingGrams: 1000);

      // small: ceil(1000/500)=2 packs; big: ceil(1000/750)=2 packs. Both solo, no distribution.
      expect(find.text("Buy 2 packs"), findsNWidgets(2));
      expect(find.text("or"), findsOneWidget);
      expect(find.text("and"), findsNothing);
    });

    testWidgets("auto-fill uses the full amount needed, not a single cycled share", (WidgetTester tester) async {
      // The auto-fill button lives on the header owned input, which renders only when no product
      // unit matches a recipe unit (otherwise per-product inputs replace it). The recipe here needs
      // pieces while the products are sold in grams, so the header fallback (and its auto-fill) shows.
      await tester.binding.setSurfaceSize(const Size(1400, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      double? captured;
      // Recommendations carry the cycled share (1 each). Auto-fill must sum them (3), not use 1.
      List<Product> products = [_equivProduct("a"), _equivProduct("b"), _equivProduct("c")];
      await _pumpProducts(
        tester,
        products: products,
        remainingGrams: 1500,
        quantitiesDesired: const [Quantity(amount: 3, unit: Unit.pieces)],
        recommendations: [_rec(products[0], 1), _rec(products[1], 1), _rec(products[2], 1)],
        onOwnedChanged: (double amount, OwnedUnit unit) => captured = amount,
      );

      await tester.tap(find.byTooltip("Auto-fill with needed amount"));
      await tester.pump();

      expect(captured, 3.0);
    });

    testWidgets("auto-fill counts one pack for two equivalents that need only one (no over-fill)", (WidgetTester tester) async {
      // Header fallback (pieces recipe, grams products) so the auto-fill button renders. See the
      // test above for why the header input, not per-product inputs, shows here.
      await tester.binding.setSurfaceSize(const Size(1400, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      double? captured;
      // Two equivalent 500 g variants, need 500 g -> 1 pack total. Recommendations come from
      // rankProducts, which cycles the single pack to [1, 0]. Auto-fill must sum to 1, not 2.
      List<Product> products = [_equivProduct("a"), _equivProduct("b")];
      List<ProductRecommendation> recommendations = rankProducts(
        totalNeeded: 500,
        events: const [],
        ingredient: Ingredient(id: "pizza", name: "Pizza", products: products),
        products: products,
      );
      await _pumpProducts(
        tester,
        products: products,
        remainingGrams: 500,
        quantitiesDesired: const [Quantity(amount: 1, unit: Unit.pieces)],
        recommendations: recommendations,
        onOwnedChanged: (double amount, OwnedUnit unit) => captured = amount,
      );

      await tester.tap(find.byTooltip("Auto-fill with needed amount"));
      await tester.pump();

      expect(captured, 1.0);
    });

    testWidgets("hides a zero-share equivalent instead of rendering '... and Covered'", (WidgetTester tester) async {
      // Two equivalent 500 g variants, need 500 g -> 1 pack total, cycled to [1, 0]. The 0-share
      // variant must not render (no "Covered"), and no dangling "and" divider appears; the single
      // visible variant renders as a normal row showing "Buy 1 pack".
      await _pumpProducts(tester, products: [_equivProduct("a"), _equivProduct("b")], remainingGrams: 500);

      expect(find.text("Buy 1 pack"), findsOneWidget);
      expect(find.text("Covered"), findsNothing);
      expect(find.text("and"), findsNothing);
      expect(find.text("or"), findsNothing);
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
