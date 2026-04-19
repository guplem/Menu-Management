import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";

class IngredientNameEditor extends StatefulWidget {
  const IngredientNameEditor({super.key, required this.ingredient, required this.onUpdate});

  final Ingredient ingredient;
  final void Function(Ingredient updatedIngredient) onUpdate;

  static void show({required BuildContext context, required Ingredient ingredient, required void Function(Ingredient updatedIngredient) onUpdate}) {
    showDialog(
      context: context,
      builder: (context) {
        return IngredientNameEditor(ingredient: ingredient, onUpdate: onUpdate);
      },
    );
  }

  @override
  State<IngredientNameEditor> createState() => _IngredientNameEditorState();
}

class _IngredientNameEditorState extends State<IngredientNameEditor> {
  late final TextEditingController _controller;
  late final TextEditingController _densityController;
  late final TextEditingController _gramsPerPieceController;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.ingredient.name);
    _densityController = TextEditingController(text: widget.ingredient.density?.toString() ?? "");
    _gramsPerPieceController = TextEditingController(text: widget.ingredient.gramsPerPiece?.toString() ?? "");
  }

  @override
  void dispose() {
    _controller.dispose();
    _densityController.dispose();
    _gramsPerPieceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Ingredient"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Ingredient Name"),
            onChanged: (String value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _densityController,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Density (g/ml)", hintText: "e.g. 1.05 for yogurt, 0.91 for oil"),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (String value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _gramsPerPieceController,
            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Grams per piece", hintText: "e.g. 150 for onion, 60 for egg"),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (String value) => setState(() {}),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        FilledButton(
          onPressed: _controller.text.trimAndSetNullIfEmpty == null
              ? null
              : () {
                  double? density = double.tryParse(_densityController.text);
                  double? gramsPerPiece = double.tryParse(_gramsPerPieceController.text);
                  final Ingredient updatedIngredient = widget.ingredient.copyWith(name: _controller.text, density: density, gramsPerPiece: gramsPerPiece);
                  widget.onUpdate(updatedIngredient);
                  IngredientsProvider.addOrUpdate(newIngredient: updatedIngredient);
                  Navigator.of(context).pop();
                },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
