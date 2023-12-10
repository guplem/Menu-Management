import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_management/recipes/models/instruction.dart';
import 'package:menu_management/recipes/recipes_provider.dart';
import 'package:menu_management/recipes/widgets/ingredient_selector.dart';
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

  onDispose() {
    descriptionController.dispose();
    workingTimeController.dispose();
    cookingTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                  setState(() {
                    newInstruction = newInstruction.copyWith(workingTimeMinutes: int.parse(value));
                  });
                  widget.onUpdate(newInstruction);
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
                  setState(() {
                    newInstruction = newInstruction.copyWith(cookingTimeMinutes: int.parse(value));
                  });
                  widget.onUpdate(newInstruction);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text('Total time: ${newInstruction.totalTimeMinutes} min', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 15),
        TextButton.icon(
          onPressed: () {
            IngredientSelector.show(
              context: context,
              originalInstruction: newInstruction,
              recipeId: widget.recipeId,
              onUpdate: (Instruction instruction) {
                setState(() {
                  newInstruction = instruction;
                });
              },
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text("Add Ingredient"),
        ),
        ...newInstruction.ingredientsUsed.map((ingredientUsed) => ListTile(
              title: Text(ingredientUsed.ingredient.name),
              trailing: IconButton(
                icon: const Icon(Icons.call_missed),
                onPressed: () {
                  setState(() {
                    newInstruction = newInstruction.copyWith(ingredientsUsed: newInstruction.ingredientsUsed.where((usage) => usage != ingredientUsed).toList());
                  });
                  widget.onUpdate(newInstruction);
                },
              ),
            )),
        const SizedBox(height: 15),
        TextField(
          controller: descriptionController,
          maxLines: null,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Description',
          ),
          onChanged: (value) {
            setState(() {
              newInstruction = newInstruction.copyWith(description: value);
            });
            widget.onUpdate(newInstruction);
          },
        ),
      ],
    );
  }
}
