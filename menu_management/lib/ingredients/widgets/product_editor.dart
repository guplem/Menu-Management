import "package:flutter/material.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";
import "package:menu_management/ingredients/models/product.dart";
import "package:menu_management/recipes/enums/unit.dart";

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
  late Unit _selectedUnit;

  @override
  void initState() {
    super.initState();
    _products = List.of(widget.ingredient.products);
    _linkController = TextEditingController();
    _itemsPerPackController = TextEditingController(text: "1");
    _quantityPerItemController = TextEditingController();
    _selectedUnit = Unit.grams;
  }

  @override
  void dispose() {
    _linkController.dispose();
    _itemsPerPackController.dispose();
    _quantityPerItemController.dispose();
    super.dispose();
  }

  void _loadProductIntoForm(int index) {
    Product product = _products[index];
    _linkController.text = product.link;
    _itemsPerPackController.text = product.itemsPerPack.toString();
    _quantityPerItemController.text = product.quantityPerItem.toString();
    _selectedUnit = product.unit;
    setState(() => _editingIndex = index);
  }

  void _clearForm() {
    _linkController.clear();
    _itemsPerPackController.text = "1";
    _quantityPerItemController.clear();
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
    return Product(
      link: _linkController.text.trim(),
      itemsPerPack: int.parse(_itemsPerPackController.text),
      quantityPerItem: double.parse(_quantityPerItemController.text),
      unit: _selectedUnit,
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
                  subtitle: Text(product.link, overflow: TextOverflow.ellipsis, maxLines: 1),
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
