import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:uuid/uuid.dart";



class RecipeAddition extends StatefulWidget {
  final void Function(String value)? onUpdate;
  const RecipeAddition({super.key, this.onUpdate});

  @override
  State<RecipeAddition> createState() => _RecipeAdditionState();
}

class _RecipeAdditionState extends State<RecipeAddition> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: "Recipe name",
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
        onChanged: (value) {
          setState(() {});
          widget.onUpdate?.call(value);
        },
        onEditingComplete: addRecipe,
        onSubmitted: (value) => addRecipe(),
      ),
    );
  }

  void addRecipe() {
    if (_controller.text.trimAndSetNullIfEmpty == null) {
      return;
    }
    RecipesProvider.addOrUpdate(
      newRecipe: Recipe(id: const Uuid().v1(), name: _controller.text, instructions: []),
    );
    setState(() {
      _controller.clear();
      widget.onUpdate?.call("");
    });
  }
}
