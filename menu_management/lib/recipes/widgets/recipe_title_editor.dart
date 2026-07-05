import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/recipes/models/recipe.dart";

class RecipeTitleEditor extends StatefulWidget {
  const RecipeTitleEditor({super.key, required this.onUpdate, required this.recipe});
  final void Function(Recipe newRecipe) onUpdate;
  final Recipe recipe;

  static void show({required BuildContext context, required Recipe recipe, required void Function(Recipe recipe) onUpdate}) {
    showDialog(
      context: context,
      builder: (context) {
        return RecipeTitleEditor(recipe: recipe, onUpdate: onUpdate);
      },
    );
  }

  @override
  State<RecipeTitleEditor> createState() => _RecipeTitleEditorState();
}

class _RecipeTitleEditorState extends State<RecipeTitleEditor> {
  late final TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.recipe.name);
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Rename recipe"),
      content: TextField(
        controller: nameController,
        maxLines: null,
        decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Name"),
        onChanged: (String value) => setState(() {}),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: nameController.text.trimAndSetNullIfEmpty == null
              ? null
              : () {
                  String txt = nameController.text;
                  widget.onUpdate(widget.recipe.copyWith(name: txt));
                  Navigator.of(context).pop();
                },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
