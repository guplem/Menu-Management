import 'package:flutter/material.dart';
import 'package:menu_management/recipes/models/instruction.dart';
import 'package:menu_management/recipes/recipes_provider.dart';
import 'package:uuid/uuid.dart';

class InstructionEditor extends StatefulWidget {
  const InstructionEditor({super.key, required this.onUpdate, required this.instruction});

  final Function(Instruction newInstruction) onUpdate;
  final Instruction? instruction;

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
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.instruction == null) {
      newInstruction = Instruction(id: const Uuid().v1(), description: '');
    } else {
      newInstruction = widget.instruction!;
      controller.text = newInstruction.description;
    }
  }

  onDispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: FocusNode()..requestFocus(),
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Description',
      ),
      onChanged: (value) {
        setState(() {
          newInstruction = newInstruction.copyWith(description: value);
        });
        widget.onUpdate(newInstruction);
      },
    );
  }
}
