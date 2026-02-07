import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/recipes/models/recipe.dart';

class RecipeTitleEditor extends StatefulWidget {
  const RecipeTitleEditor({
    Key? key,
    required this.onUpdate,
    required this.recipe,
  }) : super(key: key);
  final Function(Recipe newRecipe) onUpdate;
  final Recipe recipe;

  static show({
    required BuildContext context,
    required Recipe recipe,
    required Function(Recipe recipe) onUpdate,
  }) {
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
  late final TextEditingController outputController;

  @override
  void initState() {
    super.initState();
    outputController = TextEditingController(text: widget.recipe.name);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      title: const Text("Select an Output from another step as Input for this"),
      content: TextField(
        controller: outputController,
        maxLines: null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Output',
        ),
        onChanged: (String value) => setState(() {}),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: outputController.text.trimAndSetNullIfEmpty == null
              ? null
              : () {
                  String txt = outputController.text;
                  widget.onUpdate(widget.recipe.copyWith(name: txt));
                  Navigator.of(context).pop();
                },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
