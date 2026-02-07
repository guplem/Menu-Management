import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/quantity.dart";

class ShoppingIngredient extends StatelessWidget {
  const ShoppingIngredient({
    super.key,
    required this.ingredient,
    required this.quantitiesDesired,
    required this.onOwnedAmountChanged,
    required this.ownedQuantities,
    required this.calculatedRemainingQuantities,
  });

  final Ingredient ingredient;
  final List<Quantity> quantitiesDesired;
  final List<Quantity> ownedQuantities;
  final void Function(List<Quantity> newOwnedQuantities) onOwnedAmountChanged;
  final List<Quantity> calculatedRemainingQuantities;

  @override
  Widget build(BuildContext context) {
    return OutlinedCard(
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SizedBox(width: 350, child: Text(ingredient.name, style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(width: 10),
          Builder(
            builder: (context) {
              bool areAllRemainingQuantitiesZero = calculatedRemainingQuantities.every((quantity) => quantity.amount <= 0);
              return FilledCard(
                color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: areAllRemainingQuantitiesZero ? 0.1 : 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: quantitiesDesired.map((Quantity quantity) {
                    String amountRounded = quantity.amount.toStringAsFixed(0);
                    String unit = quantity.unit.toString().split(".").last;
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          SizedBox(width: 150, child: Text("$amountRounded $unit", style: Theme.of(context).textTheme.bodyLarge)),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 220,
                            child: TextFieldOwnedAmount(
                              unit: unit,
                              desiredAmount: quantity.amount,
                              onOwnedAmountChanged: (value) => informOfOwnedQuantitiesWith(value, quantity.unit),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: Row(
                              children: [
                                Text(
                                  calculatedRemainingQuantities.firstWhere((q) => q.unit == quantity.unit).amount.toStringAsFixed(0),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(" $unit"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  void informOfOwnedQuantitiesWith(double newOwnedValue, Unit quantityUnit) {
    List<Quantity> newQuantities = [];
    for (Quantity q in ownedQuantities) {
      if (q.unit == quantityUnit) {
        q = Quantity(amount: newOwnedValue, unit: q.unit);
      }
      newQuantities.add(q);
    }
    onOwnedAmountChanged(newQuantities);
  }
}

class TextFieldOwnedAmount extends StatefulWidget {
  const TextFieldOwnedAmount({super.key, required this.unit, required this.desiredAmount, required this.onOwnedAmountChanged});
  final String unit;
  final double desiredAmount;
  final void Function(double value) onOwnedAmountChanged;

  @override
  State<TextFieldOwnedAmount> createState() => _TextFieldOwnedAmountState();
}

class _TextFieldOwnedAmountState extends State<TextFieldOwnedAmount> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "Owned ${widget.unit}",
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.check_circle_rounded),
          onPressed: () {
            setState(() {
              controller.text = widget.desiredAmount.toString();
            });
            widget.onOwnedAmountChanged(widget.desiredAmount);
          },
        ),
      ),
      onChanged: (String value) {
        double? val = double.tryParse(value);
        if (value.isNullOrEmpty) val = 0;
        if (val == null) return;
        widget.onOwnedAmountChanged(val);
      },
    );
  }
}
