import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/ingredients/models/ingredient.dart';
import 'package:menu_management/ingredients/ingredients_provider.dart';

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
        decoration: const InputDecoration(
          labelText: 'Ingredient name',
        ),
        onChanged: (value) => setState(() {}),
        onEditingComplete: addIngredient,
        onSubmitted: (value) => addIngredient(),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.check),
        onPressed: _controller.text.trimAndSetNullIfEmpty == null
            ? null
            : () {
                addIngredient();
              },
      ),
    );
  }

  void addIngredient() {
    if (_controller.text.trimAndSetNullIfEmpty == null) {
      return;
    }
    IngredientsProvider.instance.addIngredient(
      Ingredient(name: _controller.text),
    );
    setState(() {
      _controller.clear();
    });
  }
}
