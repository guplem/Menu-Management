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
import "package:menu_management/theme/theme_custom.dart";

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
  if (ingredient != null && ingredient.products.isNotEmpty) {
    bool allSinglePiece = ingredient.products.every((Product p) => p.unit == Unit.pieces && p.totalQuantityPerPack == 1.0);
    if (allSinglePiece) return const OwnedUnit(unit: Unit.pieces);
    return const OwnedUnit(); // packs
  }

  bool hasPieces = desiredQuantities.any((q) => q.unit == Unit.pieces);
  if (hasPieces) return const OwnedUnit(unit: Unit.pieces);

  if (desiredQuantities.isNotEmpty) return OwnedUnit(unit: desiredQuantities.first.unit);

  return const OwnedUnit(unit: Unit.grams);
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
    required this.sources,
    required this.plannedTrips,
    this.combinationRecommendations = const [],
  });

  final Ingredient ingredient;
  final List<Quantity> quantitiesDesired;
  final List<Quantity> calculatedRemainingQuantities;
  final List<ProductRecommendation> productRecommendations;

  /// Waste-minimal mixed-pack recommendations (one per required unit). Only holds real mixes
  /// (2+ products); single-product picks are conveyed by the per-product "best option" chip.
  final List<CombinationRecommendation> combinationRecommendations;
  final double ownedAmount;
  final OwnedUnit ownedUnit;
  final void Function(double amount, OwnedUnit unit) onOwnedChanged;
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

  /// Highlighted line describing a recommended mixed-pack purchase, e.g.
  /// "Best value: 1x 250 grams/pack + 1x 600 grams/pack" with a waste note.
  Widget _buildCombinationBanner(CombinationRecommendation combination) {
    double waste = combination.totalWaste;
    String wasteNote = waste <= 0 ? "no waste" : "${waste.toFormattedAmount()} ${combination.selections.first.product.unit.name} waste";
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: FilledCard(
        outlined: true,
        borderColor: ThemeCustom.colorScheme(context).tertiary,
        color: ThemeCustom.colorScheme(context).tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 18, color: ThemeCustom.colorScheme(context).onTertiaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ThemeCustom.colorScheme(context).onTertiaryContainer),
                    children: [
                      const TextSpan(
                        text: "Best value: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: combinationInlineSummary(combination)),
                      TextSpan(
                        text: "  ($wasteNote)",
                        style: TextStyle(color: ThemeCustom.colorScheme(context).onTertiaryContainer.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

                // Owned quantity input with unit dropdown
                if (availableUnits.isNotEmpty) ...[
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

            // Recommended mixed-pack combination(s), shown only when a mix beats every single product.
            ...widget.combinationRecommendations.map(_buildCombinationBanner),

            // Product rows (only for products whose unit matches a required quantity)
            if (widget.ingredient.products.isNotEmpty)
              ...() {
                List<MapEntry<int, Product>> matchingProducts = widget.ingredient.products
                    .asMap()
                    .entries
                    .where((entry) => widget.quantitiesDesired.any((q) => q.unit == entry.value.unit))
                    .toList();
                List<Widget> rows = [];
                for (int i = 0; i < matchingProducts.length; i++) {
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
