import 'package:flutter/material.dart';
import 'package:menu_management/recipes/models/recipe.dart';
import 'package:menu_management/recipes/models/instruction.dart';
import 'package:menu_management/recipes/widgets/instruction_editor.dart';

class RecipePage extends StatefulWidget {
  const RecipePage({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<RecipePage> createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  late Recipe newRecipe;

  @override
  void initState() {
    super.initState();
    newRecipe = widget.recipe;
  }

  @override
  Widget build(BuildContext context) {

    return ReorderableListView.builder(
      itemCount: newRecipe.instructions.length,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          newRecipe = copyWithReorderedSteps(oldIndex: oldIndex, newIndex: newIndex);
        });
      },
      header: RecipeConfiguration(),
      itemBuilder: (context, index) {
        return ListTile(
          key: ValueKey(newRecipe.instructions[index]),
          title: Text(newRecipe.instructions[index].description),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    newRecipe = copyWithRemovedStep(index);
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: InstructionEditor.show(context, originalInstruction: newRecipe.instructions[index], onSave: (Instruction newInstruction) {
                  setState(() {
                    newRecipe = copyWithEditedStep(index, newInstruction);
                  });
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  // ignore: non_constant_identifier_names
  Widget RecipeConfiguration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilterChip(
          label: const Text('Carbs'),
          selected: newRecipe.carbs,
          onSelected: (value) {
            setState(() {
              newRecipe = newRecipe.copyWith(carbs: value);
            });
          },
        ),
        const SizedBox(width: 10),
        FilterChip(
          label: const Text('Protein'),
          selected: newRecipe.proteins,
          onSelected: (value) {
            setState(() {
              newRecipe = newRecipe.copyWith(proteins: value);
            });
          },
        ),
        const SizedBox(width: 10),
        FilterChip(
          label: const Text('Vegetables'),
          selected: newRecipe.vegetables,
          onSelected: (value) {
            setState(() {
              newRecipe = newRecipe.copyWith(vegetables: value);
            });
          },
        ),
      ],
    );
  }

  Recipe copyWithReorderedSteps({required int oldIndex, required int newIndex}) {
    List<Instruction> newSteps = newRecipe.instructions;
    Instruction instruction = newSteps.removeAt(oldIndex);
    newSteps.insert(newIndex, instruction);
    return newRecipe.copyWith(instructions: newSteps);
  }

  Recipe copyWithRemovedStep(int index) {
    List<Instruction> newSteps = newRecipe.instructions;
    newSteps.removeAt(index);
    return newRecipe.copyWith(instructions: newSteps);
  }

  Recipe copyWithEditedStep(int index, Instruction newInstruction) {
    List<Instruction> newSteps = newRecipe.instructions;
    newSteps[index] = newSteps[index] = newInstruction;
    return newRecipe.copyWith(instructions: newSteps);
  }
}
