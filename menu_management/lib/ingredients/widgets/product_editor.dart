import "package:flutter/material.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";

class ProductEditor extends StatefulWidget {
  const ProductEditor({super.key, required this.ingredient, required this.onUpdate});

  final Ingredient ingredient;
  final Function(Ingredient updatedIngredient) onUpdate;

  static void show({required BuildContext context, required Ingredient ingredient, required Function(Ingredient updatedIngredient) onUpdate}) {
    showDialog(
      context: context,
      builder: (context) {
        return ProductEditor(ingredient: ingredient, onUpdate: onUpdate);
      },
    );
  }

  @override
  State<ProductEditor> createState() => _ProductEditorState();
}

class _ProductEditorState extends State<ProductEditor> {
  late final TextEditingController _linkController;
  late final TextEditingController _itemsPerPackController;
  late final TextEditingController _quantityPerItemController;
  late Unit _selectedUnit;

  @override
  void initState() {
    super.initState();
    Product? existing = widget.ingredient.product;
    _linkController = TextEditingController(text: existing?.link ?? "");
    _itemsPerPackController = TextEditingController(text: existing?.itemsPerPack.toString() ?? "1");
    _quantityPerItemController = TextEditingController(text: existing?.quantityPerItem.toString() ?? "");
    _selectedUnit = existing?.unit ?? Unit.grams;
  }

  @override
  void dispose() {
    _linkController.dispose();
    _itemsPerPackController.dispose();
    _quantityPerItemController.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_linkController.text.trim().isEmpty) return false;
    if (int.tryParse(_itemsPerPackController.text) == null) return false;
    if (double.tryParse(_quantityPerItemController.text) == null) return false;
    int items = int.parse(_itemsPerPackController.text);
    double qty = double.parse(_quantityPerItemController.text);
    return items > 0 && qty > 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Product for ${widget.ingredient.name}"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Product URL"),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _itemsPerPackController,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Items per pack"),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityPerItemController,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Quantity per item"),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Unit>(
              initialValue: _selectedUnit,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Unit"),
              items: Unit.values.map((Unit u) => DropdownMenuItem(value: u, child: Text(u.name))).toList(),
              onChanged: (Unit? value) {
                if (value != null) setState(() => _selectedUnit = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        if (widget.ingredient.product != null)
          TextButton(
            onPressed: () {
              Ingredient updated = widget.ingredient.copyWith(product: null);
              widget.onUpdate(updated);
              IngredientsProvider.addOrUpdate(newIngredient: updated);
              Navigator.of(context).pop();
            },
            child: const Text("Remove product"),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _isValid
              ? () {
                  Product product = Product(
                    link: _linkController.text.trim(),
                    itemsPerPack: int.parse(_itemsPerPackController.text),
                    quantityPerItem: double.parse(_quantityPerItemController.text),
                    unit: _selectedUnit,
                  );
                  Ingredient updated = widget.ingredient.copyWith(product: product);
                  widget.onUpdate(updated);
                  IngredientsProvider.addOrUpdate(newIngredient: updated);
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
