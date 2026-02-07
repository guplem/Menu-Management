import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/result.dart";
import "package:uuid/uuid.dart";

class OutputCreator extends StatefulWidget {
  const OutputCreator({
    super.key,
    required this.onUpdate,
    required this.instruction,
  });
  final Function(Instruction newInstruction) onUpdate;
  final Instruction instruction;

  static void show({
    required BuildContext context,
    required Instruction instruction,
    required Function(Instruction instruction) onUpdate,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return OutputCreator(instruction: instruction, onUpdate: onUpdate);
      },
    );
  }

  @override
  State<OutputCreator> createState() => _OutputCreatorState();
}

class _OutputCreatorState extends State<OutputCreator> {
  final TextEditingController outputController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    outputController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AlertDialog(
      title: const Text("Select an Output from another step as Input for this"),
      content: TextField(
        controller: outputController,
        maxLines: null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Output",
        ),
        onChanged: (String value) => setState(() {}),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: outputController.text.trimAndSetNullIfEmpty == null
              ? null
              : () {
                  String txt = outputController.text;
                  Result newOutput = Result(
                    id: const Uuid().v1(),
                    description: txt,
                  );
                  widget.onUpdate(
                    widget.instruction.copyWith(
                      outputs: [...widget.instruction.outputs, newOutput],
                    ),
                  );
                  Navigator.of(context).pop();
                },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
