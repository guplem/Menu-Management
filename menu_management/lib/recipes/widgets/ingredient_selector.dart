import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/ingredients/ingredients_provider.dart';
import 'package:menu_management/ingredients/models/ingredient.dart';
import 'package:menu_management/recipes/enums/unit.dart';
import 'package:menu_management/recipes/models/ingredient_usage.dart';
import 'package:menu_management/recipes/models/instruction.dart';
import 'package:menu_management/recipes/models/quantity.dart';
import 'package:menu_management/recipes/recipes_provider.dart';
import 'package:uuid/uuid.dart';

class IngredientSelector extends StatefulWidget {
  const IngredientSelector({super.key, required this.onUpdate, required this.instruction});

  final Function(Instruction newInstruction) onUpdate;
  final Instruction instruction;

  @override
  State<IngredientSelector> createState() => _IngredientSelectorState();

  static show({required BuildContext context, required Instruction originalInstruction, required String recipeId, required Function(Instruction instruction) onUpdate}) {
    Instruction newInstruction = originalInstruction;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select ingredients"),
          content: IngredientSelector(
            instruction: originalInstruction,
            onUpdate: (Instruction instruction) {
              newInstruction = instruction;
            },
          ),
          actions: <Widget>[
            FilledButton(
              child: const Text('Close'),
              onPressed: () {
                onUpdate(newInstruction);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _IngredientSelectorState extends State<IngredientSelector> {
  late Instruction newInstruction;

  @override
  void initState() {
    super.initState();
    newInstruction = widget.instruction;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SearchAnchor.bar(
          barHintText: 'Search Ingredients',
          suggestionsBuilder: (BuildContext context, SearchController controller) {
            if (controller.text.isEmpty) {
              if (IngredientsProvider.instance.searchHistory.isNotEmpty) {
                return getHistoryList(controller);
              }
              return <Widget>[const Center(child: Text('No search history.'))];
            }
            return getSuggestions(controller);
          },
        ),
        ... newInstruction.ingredientsUsed.map((IngredientUsage ingredientUsage) => ListTile(
          leading: const Icon(Icons.check),
          title: Text(ingredientUsage.ingredient.name),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              setState(() {
                newInstruction = newInstruction.copyWith(ingredientsUsed: newInstruction.ingredientsUsed.where((IngredientUsage usage) => usage != ingredientUsage).toList());
              });
              widget.onUpdate(newInstruction);
            },
          ),
        )).toList(),
      ],
    );
  }

  Iterable<Widget> getSuggestions(SearchController controller) {
    final String input = controller.value.text.toLowerCase();

    List<Ingredient> ingredients = IngredientsProvider.instance.ingredients;

    return ingredients.where((Ingredient ingredient) => ingredient.name.toLowerCase().contains(input)).map(
          (Ingredient ingredient) => ListTile(
            title: Text(ingredient.name),
            trailing: IconButton(
              icon: const Icon(Icons.call_missed),
              onPressed: () {
                controller.text = ingredient.name;
                controller.selection = TextSelection.collapsed(offset: controller.text.length);
              },
            ),
            onTap: () {
              controller.closeView(ingredient.name);
              IngredientUsage ingredientUsage = IngredientUsage(
                ingredient: ingredient,
                quantity: const Quantity(ammount: 1, unit: Unit.pieces),
              );
              widget.onUpdate(newInstruction.copyWith(ingredientsUsed: [...newInstruction.ingredientsUsed, ingredientUsage]));
              IngredientsProvider.addIngredientToHistory(ingredient);
            },
          ),
        );
  }

  Iterable<Widget> getHistoryList(SearchController controller) {
    return IngredientsProvider.instance.searchHistory.map(
          (Ingredient ingredient) => ListTile(
            leading: const Icon(Icons.history),
            title: Text(ingredient.name),
            trailing: IconButton(
              icon: const Icon(Icons.call_missed),
              onPressed: () {
                controller.text = ingredient.name;
                controller.selection = TextSelection.collapsed(offset: controller.text.length);
              },
            ),
          ),
        );
  }
}
