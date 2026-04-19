import "dart:io";

import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/shopping/waste_optimizer.dart";
import "package:menu_management/theme/theme_custom.dart";

class ShoppingProductRow extends StatefulWidget {
  const ShoppingProductRow({
    super.key,
    required this.product,
    required this.recommendation,
    required this.isRecommended,
    required this.ownedPacks,
    required this.onOwnedPacksChanged,
    this.gramsPerPiece,
  });

  final Product product;
  final double? gramsPerPiece;
  final ProductRecommendation recommendation;
  final bool isRecommended;
  final double ownedPacks;
  final void Function(double packs) onOwnedPacksChanged;

  @override
  State<ShoppingProductRow> createState() => _ShoppingProductRowState();
}

class _ShoppingProductRowState extends State<ShoppingProductRow> {
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

  int get _packsToBuy {
    double ownedAmount = widget.ownedPacks * widget.product.totalQuantityPerPack;
    double remaining = widget.recommendation.packsNeeded * widget.product.totalQuantityPerPack - ownedAmount;
    if (remaining <= 0) return 0;
    return (remaining / widget.product.totalQuantityPerPack).ceil();
  }

  @override
  Widget build(BuildContext context) {
    String? packLabel = widget.product.packLabel(gramsPerPiece: widget.gramsPerPiece);
    String totalLabel = "${widget.product.totalQuantityPerPack.toStringAsFixed(0)} ${widget.product.unit.name}/pack";
    int packsToBuy = _packsToBuy;
    bool covered = packsToBuy <= 0;

    return FilledCard(
      outlined: true,
      borderColor: widget.isRecommended ? ThemeCustom.colorScheme(context).tertiary : null,
      color: ThemeCustom.colorScheme(context).secondaryContainer.withValues(alpha: covered ? 0.3 : 1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            // Pack description
            SizedBox(
              width: 160,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (packLabel != null) Text(packLabel, style: Theme.of(context).textTheme.bodyLarge),
                  Text(totalLabel, style: packLabel != null ? Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor) : Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Recommendation chip
            if (widget.isRecommended)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: const Text("Best value"),
                  backgroundColor: ThemeCustom.colorScheme(context).tertiaryContainer,
                  labelStyle: TextStyle(color: ThemeCustom.colorScheme(context).onTertiaryContainer, fontSize: 12),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ),

            if (!widget.recommendation.isViable && widget.product.shelfLifeDays != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Tooltip(
                  message: "Expires in ${widget.product.shelfLifeDays} days after opening",
                  child: Icon(Icons.warning_amber_rounded, color: ThemeCustom.colorScheme(context).error, size: 20),
                ),
              ),

            // Owned packs input
            SizedBox(
              width: 160,
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: "Owned packs",
                  hintText: "0.5 = half",
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check_circle_rounded, size: 20),
                    onPressed: () {
                      double needed = widget.recommendation.packsNeeded.toDouble();
                      setState(() => _controller.text = needed.toStringAsFixed(needed == needed.roundToDouble() ? 0 : 1));
                      widget.onOwnedPacksChanged(needed);
                    },
                  ),
                ),
                onChanged: (String value) {
                  double? val = double.tryParse(value);
                  if (value.isNullOrEmpty) val = 0;
                  if (val == null) return;
                  widget.onOwnedPacksChanged(val);
                },
              ),
            ),
            const SizedBox(width: 12),

            // Packs to buy
            SizedBox(
              width: 80,
              child: covered
                  ? Row(children: [Icon(Icons.check_rounded, color: Theme.of(context).hintColor, size: 18), const SizedBox(width: 4), Text("Covered", style: TextStyle(color: Theme.of(context).hintColor))])
                  : Text("Buy $packsToBuy", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),

            // Product link button
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded, size: 20),
              tooltip: "Open product page",
              onPressed: widget.product.link.isEmpty ? null : () => Process.run("start", [widget.product.link], runInShell: true),
            ),
          ],
        ),
      ),
    );
  }
}
