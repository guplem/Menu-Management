import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/recipes/enums/recipe_type.dart';
import 'package:menu_management/recipes/models/recipe.dart';
import 'package:menu_management/recipes/models/instruction.dart';
import 'package:menu_management/recipes/recipes_provider.dart';
import 'package:menu_management/recipes/widgets/instruction_editor.dart';

class RecipePage extends StatelessWidget {
  const RecipePage({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context) {
    Recipe recipe = RecipesProvider.listenableOf(context, recipeId);

    return ReorderableListView.builder(
      itemCount: recipe.instructions.length,
      onReorder: (int oldIndex, int newIndex) {
        // When an item is dragged to a new position in a ReorderableListView, the onReorder callback is triggered, and it provides the old and new indexes of the dragged item. However, there is a specific behavior to be aware of when adjusting these indexes.
        // If the dragged item is moved to a position down the list (i.e., to a higher index), Flutter automatically increments the newIndex by one. This increment is done to account for the placeholder that is temporarily created when an item is lifted and moved. As a result, you often need to decrement newIndex by one in your onReorder function to get the correct index where the item should be inserted.
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }
        RecipesProvider.reorderInstructions(recipeId: recipeId, oldIndex: oldIndex, newIndex: newIndex);
      },
      header: RecipeConfiguration(recipe: recipe, context: context),
      itemBuilder: (context, index) {
        Instruction instruction = recipe.instructions[index];
        return ListTile(
          key: ValueKey(instruction.id),
          title: Text(instruction.description),
          onTap: () {
            InstructionEditor.show(
              context: context,
              recipeId: recipeId,
              originalInstruction: instruction,
            );
          },
          trailing: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                RecipesProvider.removeInstruction(recipeId: recipeId, instructionId: instruction.id);
              },
            ),
          ),
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget RecipeConfiguration({required BuildContext context, required Recipe recipe}) {
    final MaterialStateProperty<Icon?> switchIcon = MaterialStateProperty.resolveWith<Icon?>((states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check_rounded);
      }
      return const Icon(Icons.close);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: RecipeType.values.map((RecipeType type) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(type.name.capitalizeFirstLetter()??"null"),
                  selected: recipe.type == type,
                  onSelected: (bool value) {
                    if (value && type == RecipeType.breakfast) {
                      recipe.copyWith(type: type, lunch: false, dinner: false).saveToProvider();
                    } else {
                      recipe.copyWith(type: type).saveToProvider();
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const SizedBox(width: 3),
              const Text("Can be stored? "),
              const SizedBox(width: 5),
              Switch(
                thumbIcon: switchIcon,
                value: recipe.canBeStored,
                onChanged: (bool value) {
                  recipe.copyWith(canBeStored: value).saveToProvider();
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Text("Good for:"),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text('Lunch'),
                selected: recipe.lunch,
                onSelected: (value) {
                  recipe.copyWith(lunch: value).saveToProvider();
                },
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text('Dinner'),
                selected: recipe.dinner,
                onSelected: (value) {
                  recipe.copyWith(dinner: value).saveToProvider();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              const Text("Contains:"),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text('Carbs'),
                selected: recipe.carbs,
                onSelected: (value) {
                  recipe.copyWith(carbs: value).saveToProvider();
                },
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text('Protein'),
                selected: recipe.proteins,
                onSelected: (value) {
                  recipe.copyWith(proteins: value).saveToProvider();
                },
              ),
              const SizedBox(width: 10),
              FilterChip(
                label: const Text('Vegetables'),
                selected: recipe.vegetables,
                onSelected: (value) {
                  recipe.copyWith(vegetables: value).saveToProvider();
                },
              ),
              const SizedBox(width: 10),
              if (recipe.carbs == false && recipe.proteins == false && recipe.vegetables == false)
                Tooltip(
                  message: "No contents selected, this might be a problem generating menus!",
                  child: Icon(Icons.warning_rounded, color: Theme.of(context).colorScheme.error),
                ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text("Add Step"),
                onPressed: () {
                  InstructionEditor.show(
                    context: context,
                    recipeId: recipeId,
                    originalInstruction: null,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Divider(),
      ],
    );
  }
}
