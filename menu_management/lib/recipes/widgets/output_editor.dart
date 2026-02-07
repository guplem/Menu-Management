import "package:flutter/material.dart";
import "package:menu_management/recipes/models/result.dart";
import "package:uuid/uuid.dart";

class OutputEditor extends StatefulWidget {
  const OutputEditor({
    super.key,
    required this.onUpdate,
    required this.output,
    required this.recipeId,
    required this.instructionId,
  });

  final Function(Result newOutput) onUpdate;
  final Result? output;
  final String recipeId, instructionId;

  @override
  State<OutputEditor> createState() => _OutputEditorState();

  static void show({
    required BuildContext context,
    required Result? originalOutput,
    required String recipeId,
    required String instructionId,
    required void Function(Result newOutput) onUpdate,
  }) {
    Result? newOutput;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit output"),
          content: OutputEditor(
            recipeId: recipeId,
            instructionId: instructionId,
            output: originalOutput,
            onUpdate: (Result output) {
              // Save the update so if the "save" button is pressed, the output is updated in the provider
              newOutput = output;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            FilledButton(
              child: const Text("Save"),
              onPressed: () {
                onUpdate(newOutput!);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class _OutputEditorState extends State<OutputEditor> {
  late Result newOutput;
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.output == null) {
      newOutput = Result(id: const Uuid().v1(), description: "");
    } else {
      newOutput = widget.output!;
    }
    descriptionController.text = newOutput.description;
  }

  void onDispose() {
    descriptionController.dispose();
    super.dispose();
  }

  void updateOutput(Result output) {
    setState(() {
      newOutput = output;
    });
    widget.onUpdate(output);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: descriptionController,
      maxLines: null,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Description",
      ),
      onChanged: (value) {
        updateOutput(newOutput.copyWith(description: value));
      },
    );
  }
}
