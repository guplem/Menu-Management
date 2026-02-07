import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";

class IngredientQuantity extends StatefulWidget {
  const IngredientQuantity({
    super.key,
    required this.onUpdate,
    required this.ingredientUsage,
  });

  final IngredientUsage ingredientUsage;
  final Function(IngredientUsage? ingredientUsage) onUpdate;

  @override
  State<IngredientQuantity> createState() => _IngredientQuantityState();
}

class _IngredientQuantityState extends State<IngredientQuantity> {
  late IngredientUsage ingredientUsage;

  final TextEditingController amountController = TextEditingController();
  bool isInvalidAmount = false;

  @override
  void initState() {
    super.initState();
    ingredientUsage = widget.ingredientUsage;
    amountController.text = ingredientUsage.quantity.amount.toString();
  }

  void updateIngredientUsage(IngredientUsage? ingredientUsage) {
    if (ingredientUsage != null) {
      setState(() {
        this.ingredientUsage = ingredientUsage;
      });
    }

    widget.onUpdate(ingredientUsage);
  }

  void onDispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        QuantityEditor(),
        const SizedBox(width: 20),
        Text(
          getProvider<IngredientsProvider>(
            context,
            listen: true,
          ).get(widget.ingredientUsage.ingredient).name,
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => updateIngredientUsage(null),
        ),
      ],
    );
  }

  // ignore: non_constant_identifier_names
  Widget QuantityEditor() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          child: TextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r"[\d.]+")),
            ],
            controller: amountController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: "New",
              errorText: isInvalidAmount ? "Invalid Amount" : null,
            ),
            onChanged: (value) {
              double? amount = double.tryParse(value);
              if (amount != null) {
                updateIngredientUsage(
                  ingredientUsage.copyWith(
                    quantity: ingredientUsage.quantity.copyWith(amount: amount),
                  ),
                );
              }
              setState(() {
                isInvalidAmount = amount == null;
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        // Unit Dropdown
        DropdownButton<Unit>(
          items: Unit.values.map((Unit unit) {
            return DropdownMenuItem(
              value: unit,
              child: Text(
                unit.toString().split(".")[1].capitalizeFirstLetter() ?? "",
              ),
            );
          }).toList(),
          value: ingredientUsage.quantity.unit,
          onChanged: (Unit? unit) {
            if (unit != null) {
              updateIngredientUsage(
                ingredientUsage.copyWith(
                  quantity: ingredientUsage.quantity.copyWith(unit: unit),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
