import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/multi_trip_planner.dart";
import "package:menu_management/shopping/shopping_product_row.dart";
import "package:menu_management/shopping/ingredient_source.dart";
import "package:menu_management/shopping/waste_optimizer.dart";

/// Represents the unit the user picks in the "owned" dropdown.
/// [unit] is null when the user picks "packs" (product-relative).
class OwnedUnit {
  const OwnedUnit({this.unit});

  /// null means "packs"
  final Unit? unit;

  String get label => unit?.name ?? "packs";

  @override
  bool operator ==(Object other) => other is OwnedUnit && other.unit == unit;

  @override
  int get hashCode => unit.hashCode;
}

/// Returns the default [OwnedUnit] for an ingredient's "owned" dropdown.
///
/// Defaults to pieces when all products are single-piece packs (1 piece per pack),
/// since packs and pieces are equivalent in that case and pieces is more intuitive.
/// Otherwise defaults to packs when the ingredient has products, since that is the most
/// practical unit for counting items at home. Falls back to pieces or the first
/// desired unit when no products are configured.
OwnedUnit defaultOwnedUnit({required Ingredient? ingredient, required List<Quantity> desiredQuantities}) {
  // Packs is only a useful default when a product row will actually render (its unit matches a
  // recipe unit). Otherwise the header owned input is the fallback, and packs cannot convert, so
  // fall through to a concrete unit the shared resolver can convert.
  if (ingredient != null && usesPerProductOwnedInputs(ingredient: ingredient, desiredQuantities: desiredQuantities)) {
    bool allSinglePiece = ingredient.products.every((Product p) => p.unit == Unit.pieces && p.totalQuantityPerPack == 1.0);
    if (allSinglePiece) return const OwnedUnit(unit: Unit.pieces);
    return const OwnedUnit(); // packs
  }

  // Prefer pieces (from a product or a recipe) so the user can count whole items, then the first
  // recipe unit, then grams.
  bool hasPieces = (ingredient?.products.any((Product p) => p.unit == Unit.pieces) ?? false) || desiredQuantities.any((q) => q.unit == Unit.pieces);
  if (hasPieces) return const OwnedUnit(unit: Unit.pieces);

  if (desiredQuantities.isNotEmpty) return OwnedUnit(unit: desiredQuantities.first.unit);

  return const OwnedUnit(unit: Unit.grams);
}

/// Whether an ingredient shows per-product owned inputs (one per product row) instead of the single
/// header owned input.
///
/// True only when the ingredient has products AND at least one product's unit matches a
/// desired-quantity unit, because a product row renders only for such products. When false (no
/// products, or products whose units never match a recipe unit, e.g. a pieces-only product used by
/// a grams recipe), the header owned input is shown as the fallback so the user can always enter
/// owned stock. Both callers (the widget's layout and `ShoppingPage`'s owned-stock resolver) use
/// this so the shown input and the subtracted amount stay in sync.
bool usesPerProductOwnedInputs({required Ingredient ingredient, required List<Quantity> desiredQuantities}) {
  return ingredient.products.any((Product product) => desiredQuantities.any((Quantity q) => q.unit == product.unit));
}

class ShoppingIngredient extends StatefulWidget {
  const ShoppingIngredient({
    super.key,
    required this.ingredient,
    required this.quantitiesDesired,
    required this.calculatedRemainingQuantities,
    required this.productRecommendations,
    required this.ownedAmount,
    required this.ownedUnit,
    required this.onOwnedChanged,
    required this.ownedProductCounts,
    required this.onProductOwnedChanged,
    required this.sources,
    required this.plannedTrips,
  });

  final Ingredient ingredient;
  final List<Quantity> quantitiesDesired;
  final List<Quantity> calculatedRemainingQuantities;
  final List<ProductRecommendation> productRecommendations;

  /// Single owned input, used only when the ingredient has no products.
  final double ownedAmount;
  final OwnedUnit ownedUnit;
  final void Function(double amount, OwnedUnit unit) onOwnedChanged;

  /// Owned count per product (product index in [Ingredient.products] -> count), used when the
  /// ingredient has products. Each product row shows its own owned input.
  final Map<int, double> ownedProductCounts;
  final void Function(int productIndex, double count) onProductOwnedChanged;

  final List<IngredientSource> sources;

  /// Planned shopping trips for the whole menu. When 2+ trips buy this ingredient,
  /// each product row shows the per-trip buy split instead of a single total.
  final List<ShoppingTrip> plannedTrips;

  @override
  State<ShoppingIngredient> createState() => _ShoppingIngredientState();
}

class _ShoppingIngredientState extends State<ShoppingIngredient> {
  late TextEditingController _controller;

  bool get _isFullyCovered => widget.calculatedRemainingQuantities.every((q) => q.amount <= 0);

  List<OwnedUnit> get _availableUnits {
    Set<Unit> seen = {};
    List<OwnedUnit> unitEntries = [];

    // Collect unique units from products
    for (Product product in widget.ingredient.products) {
      if (seen.add(product.unit)) {
        unitEntries.add(OwnedUnit(unit: product.unit));
      }
    }
    // Add unique units from desired quantities not already covered by products
    for (Quantity q in widget.quantitiesDesired) {
      if (seen.add(q.unit)) {
        unitEntries.add(OwnedUnit(unit: q.unit));
      }
    }

    // Sort: pieces first, then other base units, then packs last
    unitEntries.sort((OwnedUnit a, OwnedUnit b) {
      if (a.unit == Unit.pieces && b.unit != Unit.pieces) return -1;
      if (b.unit == Unit.pieces && a.unit != Unit.pieces) return 1;
      return 0;
    });

    // Add "packs" at the end if there are products
    if (widget.ingredient.products.isNotEmpty) {
      unitEntries.add(const OwnedUnit());
    }

    return unitEntries;
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSourcesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("${widget.ingredient.name} - Recipe Breakdown"),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Table(
                  columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1.5), 3: FlexColumnWidth(2)},
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text("Recipe", style: Theme.of(context).textTheme.titleSmall),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text("Per serving", style: Theme.of(context).textTheme.titleSmall),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text("Servings", style: Theme.of(context).textTheme.titleSmall),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text("Total", style: Theme.of(context).textTheme.titleSmall),
                        ),
                      ],
                    ),
                    ...widget.sources.map((IngredientSource source) {
                      String perServing = source.perServingQuantities.map((q) => "${q.amount.toFormattedAmount()} ${q.unit.name}").join(" + ");
                      String total = source.perServingQuantities
                          .map((q) => "${(q.amount * source.servings).toFormattedAmount()} ${q.unit.name}")
                          .join(" + ");
                      return TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(source.recipeName)),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(perServing)),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text("${source.servings}")),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text(total)),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Close"))],
        );
      },
    );
  }

  int _packsToBuyForProduct(Product product) {
    Quantity? remaining = widget.calculatedRemainingQuantities.firstWhereOrNull((q) => q.unit == product.unit);
    if (remaining == null || remaining.amount <= 0) return 0;
    return product.packsNeeded(remaining.amount);
  }

  /// Splits a product's buy count across the planned trips, mirroring the per-week sections of
  /// the copied list. Rounds each trip's amount to whole units before computing packs, exactly
  /// like `_appendIngredientLines` in shopping_page.dart, so the on-screen split matches the copy.
  /// Returns an empty list (single-total display) unless 2+ trips actually buy this product.
  List<ProductTripPurchase> _tripPurchasesForProduct(Product product) {
    if (widget.plannedTrips.length < 2) return const [];
    int firstWeek = widget.plannedTrips.first.weekIndex; // trips are sorted ascending by the planner
    List<ProductTripPurchase> purchases = [];
    for (ShoppingTrip trip in widget.plannedTrips) {
      double amount = 0;
      for (TripItem item in trip.items) {
        if (item.ingredientId == widget.ingredient.id && item.unit == product.unit) amount += item.amount;
      }
      int packs = product.packsNeeded(amount.roundToDouble());
      if (packs <= 0) continue;
      purchases.add(ProductTripPurchase(weekIndex: trip.weekIndex, packs: packs, isFirstTrip: trip.weekIndex == firstWeek));
    }
    // A row is a "split" only when 2+ trips actually buy this product.
    if (purchases.length < 2) return const [];
    return purchases;
  }

  void _autoFillOwned() {
    // Auto-fill with the total desired amount in the currently selected unit
    OwnedUnit selectedUnit = widget.ownedUnit;
    double autoValue;

    if (selectedUnit.unit == null) {
      // Packs: use the recommended product's packs needed
      ProductRecommendation? bestRec = widget.productRecommendations.firstWhereOrNull((r) => r.isViable) ?? widget.productRecommendations.firstOrNull;
      autoValue = bestRec?.packsNeeded.toDouble() ?? 0;
    } else {
      // Raw unit: use the desired quantity for that unit
      Quantity? desired = widget.quantitiesDesired.firstWhereOrNull((q) => q.unit == selectedUnit.unit);
      autoValue = desired?.amount ?? 0;
    }

    setState(() => _controller.text = autoValue.toStringAsFixed(autoValue == autoValue.roundToDouble() ? 0 : 1));
    widget.onOwnedChanged(autoValue, selectedUnit);
  }

  @override
  Widget build(BuildContext context) {
    // Determine best waste level among all recommendations.
    // A product is "best" if its totalWaste equals the minimum (includes ties and single products).
    double? bestWaste;
    if (widget.productRecommendations.isNotEmpty) {
      bestWaste = widget.productRecommendations.map((ProductRecommendation r) => r.totalWaste).reduce((double a, double b) => a < b ? a : b);
    }

    List<OwnedUnit> availableUnits = _availableUnits;

    return OutlinedCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ingredient name + owned input + remaining + help icon (far right)
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.ingredient.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _isFullyCovered ? Theme.of(context).hintColor : null),
                  ),
                ),

                // Owned quantity input with unit dropdown.
                // Shown as the fallback whenever no per-product owned inputs will render (no products,
                // or no product unit matches a recipe unit); otherwise each product row hosts its own input.
                if (!usesPerProductOwnedInputs(ingredient: widget.ingredient, desiredQuantities: widget.quantitiesDesired) &&
                    availableUnits.isNotEmpty) ...[
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        labelText: "Owned",
                        border: const OutlineInputBorder(),
                        isDense: true,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.check_circle_rounded, size: 20),
                          tooltip: "Auto-fill with needed amount",
                          onPressed: _autoFillOwned,
                        ),
                      ),
                      onChanged: (String value) {
                        double? val = double.tryParse(value);
                        if (value.isNullOrEmpty) val = 0;
                        if (val == null) return;
                        widget.onOwnedChanged(val, widget.ownedUnit);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (availableUnits.length == 1)
                    SizedBox(width: 80, child: Text(availableUnits.first.label, style: Theme.of(context).textTheme.bodyLarge))
                  else
                    SizedBox(
                      width: 120,
                      child: DropdownButtonFormField<OwnedUnit>(
                        initialValue: widget.ownedUnit,
                        isDense: true,
                        decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)),
                        items: availableUnits.map((OwnedUnit u) => DropdownMenuItem<OwnedUnit>(value: u, child: Text(u.label))).toList(),
                        onChanged: (OwnedUnit? newUnit) {
                          if (newUnit == null) return;
                          double currentAmount = double.tryParse(_controller.text) ?? 0;
                          widget.onOwnedChanged(currentAmount, newUnit);
                        },
                      ),
                    ),
                  const SizedBox(width: 16),
                ],

                // Remaining quantities
                ...widget.calculatedRemainingQuantities.map((Quantity q) {
                  if (q.amount <= 0) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded, color: Theme.of(context).hintColor, size: 18),
                          const SizedBox(width: 4),
                          Text("All set", style: TextStyle(color: Theme.of(context).hintColor)),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      "Need: ${q.amount.toFormattedAmount()} ${q.unit.name}",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  );
                }),

                // Help icon (far right)
                if (widget.sources.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: const Icon(Icons.help_outline_rounded, size: 20),
                      tooltip: "Show recipe breakdown",
                      onPressed: () => _showSourcesDialog(context),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Product rows (only for products whose unit matches a required quantity)
            if (usesPerProductOwnedInputs(ingredient: widget.ingredient, desiredQuantities: widget.quantitiesDesired))
              ...() {
                List<MapEntry<int, Product>> matchingProducts = widget.ingredient.products
                    .asMap()
                    .entries
                    .where((entry) => widget.quantitiesDesired.any((q) => q.unit == entry.value.unit))
                    .toList();
                List<Widget> rows = [];
                for (int i = 0; i < matchingProducts.length; i++) {
                  int productIndex = matchingProducts[i].key;
                  Product product = matchingProducts[i].value;
                  ProductRecommendation recommendation = widget.productRecommendations.firstWhere(
                    (r) => r.product == product,
                    orElse: () => ProductRecommendation(product: product, packsNeeded: 0, overBuyWaste: 0, expiryWaste: 0, isViable: true),
                  );
                  if (i > 0) {
                    rows.add(
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text("or", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                      ),
                    );
                  }
                  rows.add(
                    ShoppingProductRow(
                      product: product,
                      recommendation: recommendation,
                      isBestOption: bestWaste != null && recommendation.totalWaste == bestWaste,
                      packsToBuy: _packsToBuyForProduct(product),
                      tripPurchases: _tripPurchasesForProduct(product),
                      ownedCount: widget.ownedProductCounts[productIndex] ?? 0,
                      onOwnedCountChanged: (double count) => widget.onProductOwnedChanged(productIndex, count),
                    ),
                  );
                }
                return rows;
              }(),
          ],
        ),
      ),
    );
  }
}
