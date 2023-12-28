import 'package:flutter/material.dart';
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
            children: RecipeType.values.map((e) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FilterChip(
                  label: Text(e.name),
                  selected: recipe.type == e,
                  onSelected: (value) {
                    recipe.copyWith(type: e).saveToProvider();
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
