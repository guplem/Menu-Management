import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/ingredients/models/ingredient.dart";

class IngredientNameEditor extends StatefulWidget {
  const IngredientNameEditor({super.key, required this.ingredient, required this.onUpdate});

  final Ingredient ingredient;
  final Function(Ingredient updatedIngredient) onUpdate;

  static void show({required BuildContext context, required Ingredient ingredient, required Function(Ingredient updatedIngredient) onUpdate}) {
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.ingredient.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Ingredient Name"),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Ingredient Name"),
        onChanged: (String value) => setState(() {}), // Trigger rebuild to update Save button state
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
                  final Ingredient updatedIngredient = widget.ingredient.copyWith(name: _controller.text);
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
