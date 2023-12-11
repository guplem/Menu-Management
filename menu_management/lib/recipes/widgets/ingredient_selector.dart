import 'package:flutter/material.dart';
import 'package:menu_management/ingredients/ingredients_provider.dart';
import 'package:menu_management/ingredients/models/ingredient.dart';
import 'package:menu_management/recipes/enums/unit.dart';
import 'package:menu_management/recipes/models/ingredient_usage.dart';
import 'package:menu_management/recipes/models/instruction.dart';
import 'package:menu_management/recipes/models/quantity.dart';
import 'package:menu_management/recipes/widgets/ingredient_quantity.dart';

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

  void updateInstruction(Instruction instruction) {
    setState(() {
      newInstruction = instruction;
    });
    widget.onUpdate(instruction);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
        const SizedBox(height: 15),
        ...newInstruction.ingredientsUsed
            .map((IngredientUsage ingredientUsage) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7.0),
              child: IngredientQuantity(
                    ingredientUsage: ingredientUsage,
                    onUpdate: (IngredientUsage? newUsage) {
                      Instruction updatedInstruction;
                      if (newUsage != null) {
                        // Update the ingredient
                        updatedInstruction = newInstruction.copyWith(
                          ingredientsUsed: newInstruction.ingredientsUsed.map((IngredientUsage ing) {
                            if (ing.ingredient == ingredientUsage.ingredient) {
                              return newUsage;
                            }
                            return ing;
                          }).toList(),
                        );
                      } else {
                        // Remove the ingredient
                        updatedInstruction = newInstruction.copyWith(
                          ingredientsUsed: newInstruction.ingredientsUsed.where((IngredientUsage ing) => ing.ingredient != ingredientUsage.ingredient).toList(),
                        );
                      }
                      updateInstruction(updatedInstruction);
                    },
                  ),
            ))
            .toList(),
      ],
    );
  }

  Iterable<Widget> getSuggestions(SearchController controller) {
    final String input = controller.value.text.toLowerCase();

    List<Ingredient> ingredients = IngredientsProvider.instance.ingredients;

    return ingredients.where((Ingredient ingredient) => ingredient.name.toLowerCase().contains(input)).map(
          (Ingredient ingredient) => IngredientSuggestion(ingredient: ingredient, controller: controller, isHistory: false),
        );
  }

  Iterable<Widget> getHistoryList(SearchController controller) {
    return IngredientsProvider.instance.searchHistory.map(
      (Ingredient ingredient) => IngredientSuggestion(ingredient: ingredient, controller: controller, isHistory: true),
    );
  }

  // ignore: non_constant_identifier_names
  Widget IngredientSuggestion({required Ingredient ingredient, required SearchController controller, required bool isHistory}) {
    bool alreadyUsed = newInstruction.ingredientsUsed.any((IngredientUsage ing) => ing.ingredient == ingredient);
    return ListTile(
      title: Text(ingredient.name),
      leading: isHistory ? const Icon(Icons.history_rounded) : null,
      trailing: IconButton(
        icon: const Icon(Icons.call_missed_rounded),
        onPressed: () {
          controller.text = ingredient.name;
          controller.selection = TextSelection.collapsed(offset: controller.text.length);
        },
      ),
      onTap: alreadyUsed
          ? null
          : () {
              selectIngredient(controller: controller, ingredient: ingredient);
            },
    );
  }

  void selectIngredient({required Ingredient ingredient, required SearchController controller}) {
    // Check if the ingredient is already in the list
    if (newInstruction.ingredientsUsed.any((IngredientUsage ing) => ing.ingredient == ingredient)) {
      return;
    }
    // Close the search bar
    controller.closeView("");
    // Add the ingredient to the list
    IngredientUsage ingredientUsage = IngredientUsage(
      ingredient: ingredient,
      quantity: const Quantity(amount: 1, unit: Unit.pieces),
    );
    updateInstruction(newInstruction.copyWith(ingredientsUsed: [...newInstruction.ingredientsUsed, ingredientUsage]));
    IngredientsProvider.addIngredientToHistory(ingredient);
  }
}
