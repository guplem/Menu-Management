import 'package:flutter/material.dart';
import 'package:menu_management/recipes/models/instruction.dart';
import 'package:menu_management/recipes/models/result.dart';
import 'package:menu_management/recipes/recipes_provider.dart';
import 'package:uuid/uuid.dart';

class InputSelector extends StatefulWidget {
  const InputSelector({
    super.key,
    required this.onUpdate,
    required this.instruction,
    required this.recipeId,
  });

  final Function(Instruction newInstruction) onUpdate;
  final Instruction? instruction;
  final String recipeId;

  @override
  State<InputSelector> createState() => _InputSelectorState();

  static void show({
    required BuildContext context,
    required Instruction originalInstruction,
    required String recipeId,
    required Function(Instruction instruction) onUpdate,
  }) {
    Instruction newInstruction = originalInstruction;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Select an Output from another step as Input for this",
          ),
          content: InputSelector(
            instruction: originalInstruction,
            onUpdate: (Instruction instruction) {
              newInstruction = instruction;
            },
            recipeId: recipeId,
          ),
          actions: <Widget>[
            FilledButton(
              child: const Text('Save'),
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

class _InputSelectorState extends State<InputSelector> {
  late Instruction newInstruction;

  /// True means it can be selected, false means it's already selected (by another instruction/step)
  late final Map<Result, bool> allPossibleInputs;

  @override
  void initState() {
    super.initState();
    newInstruction =
        widget.instruction ??
        Instruction(
          id: const Uuid().v1(),
          description: '',
          ingredientsUsed: [],
          outputs: [],
        );
    allPossibleInputs = RecipesProvider().getRecipeInputsAvailability(
      recipeId: widget.recipeId,
      forInstruction: newInstruction.id,
    );
    allPossibleInputs.addAll({
      for (Result output in newInstruction.outputs) output: false,
    });
  }

  void updateInstruction(Instruction instruction) {
    setState(() => newInstruction = instruction);
    widget.onUpdate(instruction);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (final Result possibleInput in allPossibleInputs.keys)
            CheckboxListTile(
              title: Text(possibleInput.description),
              isError: !(allPossibleInputs[possibleInput] ?? true),
              enabled:
                  newInstruction.inputs.contains(possibleInput.id) ||
                  (allPossibleInputs[possibleInput] ?? false),
              value: newInstruction.inputs.contains(possibleInput.id),
              onChanged: (bool? value) {
                if (value == null) return;
                List<Result> instructionInputs = RecipesProvider().getResults(
                  newInstruction.inputs,
                );
                if (value) {
                  instructionInputs.add(possibleInput);
                } else {
                  instructionInputs.remove(possibleInput);
                }
                updateInstruction(
                  newInstruction.copyWith(
                    inputs: instructionInputs.map((e) => e.id).toList(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
