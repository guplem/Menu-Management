import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/widgets/instruction_editor.dart";

void main() {
  group("InstructionEditor time fields", () {
    const Instruction instruction = Instruction(id: "step-1", description: "Boil", workingTimeMinutes: 10, cookingTimeMinutes: 20);

    Future<void> pumpEditor(WidgetTester tester, {required void Function(Instruction newInstruction) onUpdate}) async {
      tester.view.physicalSize = const Size(1200, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: InstructionEditor(instruction: instruction, recipeId: "recipe-1", onUpdate: onUpdate),
            ),
          ),
        ),
      );
    }

    testWidgets("stores the result of arithmetic in the cooking time", (WidgetTester tester) async {
      Instruction? updated;
      await pumpEditor(tester, onUpdate: (Instruction newInstruction) => updated = newInstruction);

      await tester.enterText(find.widgetWithText(TextField, "Cooking time"), "30/2");
      await tester.pump();

      expect(updated?.cookingTimeMinutes, 15);
    });

    testWidgets("ignores an empty cooking time instead of crashing", (WidgetTester tester) async {
      // The field used int.parse, which throws on empty text when the user clears the field.
      Instruction? updated;
      await pumpEditor(tester, onUpdate: (Instruction newInstruction) => updated = newInstruction);

      await tester.enterText(find.widgetWithText(TextField, "Cooking time"), "");
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(updated, isNull);
    });

    testWidgets("ignores a negative working time", (WidgetTester tester) async {
      Instruction? updated;
      await pumpEditor(tester, onUpdate: (Instruction newInstruction) => updated = newInstruction);

      await tester.enterText(find.widgetWithText(TextField, "Working time"), "5-10");
      await tester.pump();

      expect(updated, isNull);
    });
  });
}
