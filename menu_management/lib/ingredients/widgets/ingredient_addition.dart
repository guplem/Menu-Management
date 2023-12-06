import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/ingredients/models/ingredient.dart';
import 'package:menu_management/ingredients/ingredients_provider.dart';
import 'package:uuid/uuid.dart';

class IngredientAddition extends StatefulWidget {
  const IngredientAddition({super.key});

  @override
  State<IngredientAddition> createState() => _IngredientAdditionState();
}

class _IngredientAdditionState extends State<IngredientAddition> {
  final TextEditingController _controller = TextEditingController();

  onDispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        // focusNode: FocusNode()..requestFocus(),
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Ingredient name',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded),
            onPressed: _controller.text.trimAndSetNullIfEmpty == null
                ? null
                : () {
                    addIngredient();
                  },
          ),
        ),
        onChanged: (value) => setState(() {}),
        onEditingComplete: addIngredient,
        onSubmitted: (value) => addIngredient(),
      ),
    );
  }

  void addIngredient() {
    if (_controller.text.trimAndSetNullIfEmpty == null) {
      return;
    }
    IngredientsProvider.addOrUpdate(
      newIngredient: Ingredient(id: const Uuid().v1(), name: _controller.text),
    );
    setState(() {
      _controller.clear();
    });
  }
}
