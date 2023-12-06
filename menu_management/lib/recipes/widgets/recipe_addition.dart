import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/recipes/models/recipe.dart';
import 'package:menu_management/recipes/recipes_provider.dart';
import 'package:uuid/uuid.dart';

class RecipeAddition extends StatefulWidget {
  const RecipeAddition({super.key});

  @override
  State<RecipeAddition> createState() => _RecipeAdditionState();
}

class _RecipeAdditionState extends State<RecipeAddition> {
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
          labelText: 'Recipe name',
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded),
            onPressed: _controller.text.trimAndSetNullIfEmpty == null
                ? null
                : () {
              addRecipe();
            },
          ),
        ),
        onChanged: (value) => setState(() {}),
        onEditingComplete: addRecipe,
        onSubmitted: (value) => addRecipe(),
      ),
    );
  }

  void addRecipe() {
    if (_controller.text.trimAndSetNullIfEmpty == null) {
      return;
    }
    RecipesProvider.addOrUpdate(newRecipe:
      Recipe(id: const Uuid().v1(), name: _controller.text, instructions: []),
    );
    setState(() {
      _controller.clear();
    });
  }
}
