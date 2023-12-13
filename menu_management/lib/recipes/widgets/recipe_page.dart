import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              Flexible(
                flex: 1,
                child: TextField(
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: recipe.maxStorageDays.toString(),
                      selection: TextSelection.collapsed(
                        offset: recipe.maxStorageDays.toString().length,
                      ),
                    ),
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Maximum Days in Storage',
                    border: OutlineInputBorder(),
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    int? valueInt = int.tryParse(value);
                    if (valueInt != null) {
                      recipe.copyWith(maxStorageDays: valueInt).saveToProvider();
                    }
                  },
                ),
              ),
              const Flexible(
                flex: 3,
                child: SizedBox.shrink(),
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
