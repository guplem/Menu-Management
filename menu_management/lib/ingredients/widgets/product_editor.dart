import "package:flutter/material.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";
import "dart:io";

class ProductEditor extends StatefulWidget {
  const ProductEditor({super.key, required this.ingredient, required this.onUpdate});

  final Ingredient ingredient;
  final void Function(Ingredient updatedIngredient) onUpdate;

  static void show({required BuildContext context, required Ingredient ingredient, required void Function(Ingredient updatedIngredient) onUpdate}) {
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
  late List<Product> _products;
  int? _editingIndex;

  late final TextEditingController _linkController;
  late final TextEditingController _itemsPerPackController;
  late final TextEditingController _quantityPerItemController;
  late final TextEditingController _shelfLifeDaysOpenedController;
  late final TextEditingController _shelfLifeDaysClosedController;
  late Unit _selectedUnit;

  @override
  void initState() {
    super.initState();
    _products = List.of(widget.ingredient.products);
    _linkController = TextEditingController();
    _itemsPerPackController = TextEditingController(text: "1");
    _quantityPerItemController = TextEditingController();
    _shelfLifeDaysOpenedController = TextEditingController();
    _shelfLifeDaysClosedController = TextEditingController();
    _selectedUnit = Unit.grams;
  }

  @override
  void dispose() {
    _linkController.dispose();
    _itemsPerPackController.dispose();
    _quantityPerItemController.dispose();
    _shelfLifeDaysOpenedController.dispose();
    _shelfLifeDaysClosedController.dispose();
    super.dispose();
  }

  void _loadProductIntoForm(int index) {
    Product product = _products[index];
    _linkController.text = product.link;
    _itemsPerPackController.text = product.itemsPerPack.toString();
    _quantityPerItemController.text = product.quantityPerItem.toString();
    _shelfLifeDaysOpenedController.text = product.shelfLifeDaysOpened?.toString() ?? "";
    _shelfLifeDaysClosedController.text = product.shelfLifeDaysClosed?.toString() ?? "";
    _selectedUnit = product.unit;
    setState(() => _editingIndex = index);
  }

  void _clearForm() {
    _linkController.clear();
    _itemsPerPackController.text = "1";
    _quantityPerItemController.clear();
    _shelfLifeDaysOpenedController.clear();
    _shelfLifeDaysClosedController.clear();
    _selectedUnit = Unit.grams;
    setState(() => _editingIndex = null);
  }

  bool get _hasChanges {
    if (_isFormValid) return true;
    if (_products.length != widget.ingredient.products.length) return true;
    for (int i = 0; i < _products.length; i++) {
      if (_products[i] != widget.ingredient.products[i]) return true;
    }
    return false;
  }

  bool get _isFormValid {
    if (_linkController.text.trim().isEmpty) return false;
    if (int.tryParse(_itemsPerPackController.text) == null) return false;
    if (double.tryParse(_quantityPerItemController.text) == null) return false;
    int items = int.parse(_itemsPerPackController.text);
    double qty = double.parse(_quantityPerItemController.text);
    return items > 0 && qty > 0;
  }

  Product _buildProductFromForm() {
    int? shelfLifeDaysOpened = int.tryParse(_shelfLifeDaysOpenedController.text);
    int? shelfLifeDaysClosed = int.tryParse(_shelfLifeDaysClosedController.text);
    return Product(
      link: _linkController.text.trim(),
      itemsPerPack: int.parse(_itemsPerPackController.text),
      quantityPerItem: double.parse(_quantityPerItemController.text),
      unit: _selectedUnit,
      shelfLifeDaysOpened: shelfLifeDaysOpened,
      shelfLifeDaysClosed: shelfLifeDaysClosed,
    );
  }

  void _saveAndClose() {
    if (_isFormValid) {
      if (_editingIndex != null) {
        _products[_editingIndex!] = _buildProductFromForm();
      } else {
        _products.add(_buildProductFromForm());
      }
    }
    Ingredient updated = widget.ingredient.copyWith(products: _products);
    widget.onUpdate(updated);
    IngredientsProvider.addOrUpdate(newIngredient: updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Products for ${widget.ingredient.name}"),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_products.isNotEmpty) ...[
              Text("Linked products:", style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              ..._products.asMap().entries.map((entry) {
                int index = entry.key;
                Product product = entry.value;
                bool isEditing = _editingIndex == index;
                return ListTile(
                  dense: true,
                  selected: isEditing,
                  title: Text("${product.itemsPerPack} x ${product.quantityPerItem.toStringAsFixed(0)} ${product.unit.name}"),
                  subtitle: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Process.run("start", [product.link], runInShell: true),
                      child: Text(
                        product.link,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _loadProductIntoForm(index)),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          setState(() {
                            _products.removeAt(index);
                            if (_editingIndex == index) _clearForm();
                            if (_editingIndex != null && _editingIndex! > index) _editingIndex = _editingIndex! - 1;
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              const Divider(),
            ],
            Text(_editingIndex != null ? "Edit product:" : "Add product:", style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
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
            const SizedBox(height: 12),
            TextField(
              controller: _shelfLifeDaysOpenedController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Shelf life after opening (days)",
                hintText: "Leave empty if it does not go bad once opened",
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _shelfLifeDaysClosedController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Shelf life sealed (days from purchase)",
                hintText: "Leave empty for indefinite when sealed",
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.tonalIcon(
                  icon: Icon(_editingIndex != null ? Icons.check : Icons.add),
                  label: Text(_editingIndex != null ? "Update" : "Add"),
                  onPressed: _isFormValid
                      ? () {
                          setState(() {
                            if (_editingIndex != null) {
                              _products[_editingIndex!] = _buildProductFromForm();
                            } else {
                              _products.add(_buildProductFromForm());
                            }
                          });
                          _clearForm();
                        }
                      : null,
                ),
                if (_editingIndex != null) ...[const SizedBox(width: 8), TextButton(onPressed: _clearForm, child: const Text("Cancel edit"))],
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
        FilledButton(onPressed: _hasChanges ? _saveAndClose : null, child: const Text("Save")),
      ],
    );
  }
}
