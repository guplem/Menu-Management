import 'package:flutter/material.dart';
import 'package:menu_management/recipes/models/instruction.dart';

class InstructionEditor extends StatefulWidget {
  const InstructionEditor({super.key, required this.onUpdate, required this.instruction});

  final Function(Instruction newInstruction) onUpdate;
  final Instruction instruction;

  @override
  State<InstructionEditor> createState() => _InstructionEditorState();

  static show(BuildContext context, {required Instruction originalInstruction, required Function(Instruction newInstruction) onSave}) {
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
                onSave(newInstruction!);
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

  @override
  void initState() {
    super.initState();
    newInstruction = widget.instruction;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        labelText: 'Instruction',
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
