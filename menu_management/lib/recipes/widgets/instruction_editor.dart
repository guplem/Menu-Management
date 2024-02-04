import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_management/recipes/models/ingredient_usage.dart';
import 'package:menu_management/recipes/models/instruction.dart';
import 'package:menu_management/recipes/models/result.dart';
import 'package:menu_management/recipes/recipes_provider.dart';
import 'package:menu_management/recipes/widgets/ingredient_quantity.dart';
import 'package:menu_management/recipes/widgets/ingredient_selector.dart';
import 'package:menu_management/recipes/widgets/input_selector.dart';
import 'package:menu_management/recipes/widgets/output_creator.dart';
import 'package:menu_management/recipes/widgets/output_editor.dart';
import 'package:uuid/uuid.dart';

class InstructionEditor extends StatefulWidget {
  const InstructionEditor({super.key, required this.onUpdate, required this.instruction, required this.recipeId});

  final Function(Instruction newInstruction) onUpdate;
  final Instruction? instruction;
  final String recipeId;

  @override
  State<InstructionEditor> createState() => _InstructionEditorState();

  static show({required BuildContext context, required Instruction? originalInstruction, required String recipeId}) {
    Instruction? newInstruction;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit instruction"),
          content: InstructionEditor(
            recipeId: recipeId,
            instruction: originalInstruction,
            onUpdate: (Instruction instruction) {
              // Save the update so if the "save" button is pressed, the instruction is updated in the provider
              newInstruction = instruction;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              child: const Text('Save'),
              onPressed: () {
                if (newInstruction != null) {
                  RecipesProvider.addOrUpdateInstruction(recipeId: recipeId, newInstruction: newInstruction!);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _InstructionEditorState extends State<InstructionEditor> {
  late Instruction newInstruction;
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController workingTimeController = TextEditingController();
  final TextEditingController cookingTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.instruction == null) {
      newInstruction = Instruction(
        id: const Uuid().v1(),
        description: '',
        cookingTimeMinutes: 10,
        workingTimeMinutes: 10,
      );
    } else {
      newInstruction = widget.instruction!;
    }
    descriptionController.text = newInstruction.description;
    workingTimeController.text = newInstruction.workingTimeMinutes.toString();
    cookingTimeController.text = newInstruction.cookingTimeMinutes.toString();
  }

  void updateInstruction(Instruction instruction) {
    setState(() {
      newInstruction = instruction;
    });
    widget.onUpdate(instruction);
  }

  onDispose() {
    descriptionController.dispose();
    workingTimeController.dispose();
    cookingTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: descriptionController,
            maxLines: null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Description',
            ),
            onChanged: (value) {
              updateInstruction(newInstruction.copyWith(description: value));
            },
          ),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 15),
          Row(
            children: [
              Flexible(
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: workingTimeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Working time',
                    suffixText: 'min',
                    suffixIcon: Icon(Icons.restaurant_menu_rounded),
                  ),
                  onChanged: (value) {
                    updateInstruction(newInstruction.copyWith(workingTimeMinutes: int.parse(value)));
                  },
                ),
              ),
              const SizedBox(width: 15),
              Flexible(
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  controller: cookingTimeController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Cooking time',
                    suffixText: 'min',
                    suffixIcon: Icon(Icons.takeout_dining_rounded),
                  ),
                  onChanged: (value) {
                    updateInstruction(newInstruction.copyWith(cookingTimeMinutes: int.parse(value)));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Total time: ${newInstruction.totalTimeMinutes} min', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  InputSelector.show(
                    context: context,
                    originalInstruction: newInstruction,
                    recipeId: widget.recipeId,
                    onUpdate: (Instruction instruction) => updateInstruction(instruction),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text("Add Input from other Step"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...RecipesProvider().getResults(newInstruction.inputs).map((Result input) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: ListTile(
                title: Text(input.description),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    updateInstruction(newInstruction.copyWith(inputs: newInstruction.inputs.where((existingInput) => existingInput != input.id).toList()));
                  },
                ),
              ),
            );
          }),
          if (newInstruction.inputs.isNotEmpty) const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  IngredientSelector.show(
                    context: context,
                    originalInstruction: newInstruction,
                    recipeId: widget.recipeId,
                    onUpdate: (Instruction instruction) => updateInstruction(instruction),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text("Add Ingredient"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...newInstruction.ingredientsUsed.map((ingredientUsage) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
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
              )),
          if (newInstruction.ingredientsUsed.isNotEmpty) const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () {
                  OutputCreator.show(
                    context: context,
                    instruction: newInstruction,
                    onUpdate: (Instruction instruction) => updateInstruction(instruction),
                  );
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text("Add Output"),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...newInstruction.outputs.map(
            (output) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: ListTile(
                leading: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    OutputEditor.show(
                      context: context,
                      originalOutput: output,
                      recipeId: widget.recipeId,
                      instructionId: newInstruction.id,
                      onUpdate: (Result newOutput) => updateInstruction(newInstruction.copyWith(outputs: newInstruction.outputs.map((existingOutput) => existingOutput.id == newOutput.id ? newOutput : existingOutput).toList())),
                    );
                  },
                ),
                title: Text(output.description),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    updateInstruction(newInstruction.copyWith(outputs: newInstruction.outputs.where((o) => o.id != output.id).toList()));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
