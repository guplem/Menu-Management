import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";
import "package:menu_management/shopping/shopping_product_row.dart";
import "package:menu_management/shopping/waste_optimizer.dart";

class ShoppingIngredient extends StatelessWidget {
  const ShoppingIngredient({
    super.key,
    required this.ingredient,
    required this.quantitiesDesired,
    required this.calculatedRemainingQuantities,
    required this.productRecommendations,
    required this.ownedPacksPerProduct,
    required this.ownedRaw,
    required this.onPacksChanged,
    required this.onRawOwnedChanged,
    required this.dailyUsage,
  });

  final Ingredient ingredient;
  final List<Quantity> quantitiesDesired;
  final List<Quantity> calculatedRemainingQuantities;
  final List<ProductRecommendation> productRecommendations;
  final Map<int, double> ownedPacksPerProduct;
  final List<Quantity> ownedRaw;
  final void Function(int productIndex, double packs) onPacksChanged;
  final void Function(List<Quantity> rawOwned) onRawOwnedChanged;
  final double dailyUsage;

  bool get _isFullyCovered => calculatedRemainingQuantities.every((q) => q.amount <= 0);

  @override
  Widget build(BuildContext context) {
    // Find the best (first viable, or first overall) recommendation
    int? bestProductIndex;
    if (productRecommendations.length > 1) {
      ProductRecommendation? bestViable = productRecommendations.firstWhereOrNull((r) => r.isViable);
      ProductRecommendation best = bestViable ?? productRecommendations.first;
      bestProductIndex = ingredient.products.indexOf(best.product);
    }

    return OutlinedCard(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ingredient name + total remaining
            Row(
              children: [
                Expanded(
                  child: Text(
                    ingredient.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _isFullyCovered ? Theme.of(context).hintColor : null),
                  ),
                ),
                ...calculatedRemainingQuantities.map((Quantity q) {
                  if (q.amount <= 0) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.check_rounded, color: Theme.of(context).hintColor, size: 18), const SizedBox(width: 4), Text("All set", style: TextStyle(color: Theme.of(context).hintColor))],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text("Need: ${q.amount.toStringAsFixed(0)} ${q.unit.name}", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  );
                }),
              ],
            ),
            const SizedBox(height: 8),

            // Product rows (if products exist)
            if (ingredient.products.isNotEmpty)
              ...ingredient.products.asMap().entries.map((MapEntry<int, Product> entry) {
                int productIndex = entry.key;
                Product product = entry.value;

                // Find recommendation for this product
                ProductRecommendation recommendation = productRecommendations.firstWhere(
                  (r) => r.product == product,
                  orElse: () => ProductRecommendation(product: product, packsNeeded: 0, overBuyWaste: 0, expiryWaste: 0, isViable: true),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ShoppingProductRow(
                    product: product,
                    recommendation: recommendation,
                    isRecommended: bestProductIndex == productIndex,
                    ownedPacks: ownedPacksPerProduct[productIndex] ?? 0,
                    onOwnedPacksChanged: (double packs) => onPacksChanged(productIndex, packs),
                  ),
                );
              }),

            // Raw unit fallback (no products)
            if (ingredient.products.isEmpty)
              ...quantitiesDesired.map((Quantity quantity) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _NoProductRow(
                    quantity: quantity,
                    remainingAmount: calculatedRemainingQuantities.firstWhere((q) => q.unit == quantity.unit, orElse: () => Quantity(amount: 0, unit: quantity.unit)),
                    ownedQuantity: ownedRaw.firstWhere((q) => q.unit == quantity.unit, orElse: () => Quantity(amount: 0, unit: quantity.unit)),
                    onOwnedAmountChanged: (double value, Unit unit) {
                      List<Quantity> newOwned = ownedRaw.map((q) => q.unit == unit ? Quantity(amount: value, unit: unit) : q).toList();
                      onRawOwnedChanged(newOwned);
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _NoProductRow extends StatefulWidget {
  const _NoProductRow({required this.quantity, required this.remainingAmount, required this.ownedQuantity, required this.onOwnedAmountChanged});

  final Quantity quantity;
  final Quantity remainingAmount;
  final Quantity ownedQuantity;
  final void Function(double value, Unit unit) onOwnedAmountChanged;

  @override
  State<_NoProductRow> createState() => _NoProductRowState();
}

class _NoProductRowState extends State<_NoProductRow> {
  late TextEditingController _controller;

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

  @override
  Widget build(BuildContext context) {
    String unit = widget.quantity.unit.name;
    bool covered = widget.remainingAmount.amount <= 0;

    return FilledCard(
      color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: covered ? 0.3 : 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            SizedBox(width: 200, child: Text("${widget.quantity.amount.toStringAsFixed(0)} $unit", style: Theme.of(context).textTheme.bodyLarge)),
            const SizedBox(width: 10),
            SizedBox(
              width: 200,
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Owned $unit",
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    onPressed: () {
                      setState(() => _controller.text = widget.quantity.amount.toString());
                      widget.onOwnedAmountChanged(widget.quantity.amount, widget.quantity.unit);
                    },
                  ),
                ),
                onChanged: (String value) {
                  double? val = double.tryParse(value);
                  if (value.isNullOrEmpty) val = 0;
                  if (val == null) return;
                  widget.onOwnedAmountChanged(val, widget.quantity.unit);
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 150,
              child: covered
                  ? Row(children: [Icon(Icons.check_rounded, color: Theme.of(context).hintColor, size: 18), const SizedBox(width: 4), Text("Covered", style: TextStyle(color: Theme.of(context).hintColor))])
                  : Text("${widget.remainingAmount.amount.toStringAsFixed(0)} $unit remaining", style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}
