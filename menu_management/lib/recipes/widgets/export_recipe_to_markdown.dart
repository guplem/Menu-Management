import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/ingredients/ingredients_provider.dart";
import "package:menu_management/recipes/models/ingredient_usage.dart";
import "package:menu_management/recipes/models/instruction.dart";
import "package:menu_management/recipes/models/recipe.dart";

class ExportRecipeToMarkdown extends StatefulWidget {
  const ExportRecipeToMarkdown({super.key, required this.recipe});

  final Recipe recipe;

  static void show({required BuildContext context, required Recipe recipe}) {
    showDialog(
      context: context,
      builder: (context) {
        return ExportRecipeToMarkdown(recipe: recipe);
      },
    );
  }

  @override
  State<ExportRecipeToMarkdown> createState() => _ExportRecipeToMarkdownState();
}

class _ExportRecipeToMarkdownState extends State<ExportRecipeToMarkdown> {
  late final TextEditingController servingsController;

  @override
  void initState() {
    super.initState();
    servingsController = TextEditingController(text: "1");
  }

  @override
  void dispose() {
    servingsController.dispose();
    super.dispose();
  }

  String _generateMarkdown({required int servings}) {
    final StringBuffer markdown = StringBuffer();

    // Recipe name as title
    markdown.writeln("# ${widget.recipe.name}");
    markdown.writeln();

    // Servings info
    markdown.writeln("**Servings:** $servings");
    markdown.writeln();

    // Total time information
    markdown.writeln("**Total Time:** ${widget.recipe.totalTimeMinutes} minutes");
    markdown.writeln("- Working Time: ${widget.recipe.workingTimeMinutes} minutes");
    markdown.writeln("- Cooking Time: ${widget.recipe.cookingTimeMinutes} minutes");
    markdown.writeln();

    // Collect all ingredients across all instructions
    final Map<String, Map<String, double>> ingredientsByUnit = {};

    for (final Instruction instruction in widget.recipe.instructions) {
      for (final IngredientUsage usage in instruction.ingredientsUsed) {
        final String ingredientId = usage.ingredient;
        final String unit = usage.quantity.unit.name;
        final double amount = usage.quantity.amount * servings;

        if (!ingredientsByUnit.containsKey(ingredientId)) {
          ingredientsByUnit[ingredientId] = {};
        }

        if (!ingredientsByUnit[ingredientId]!.containsKey(unit)) {
          ingredientsByUnit[ingredientId]![unit] = 0;
        }

        ingredientsByUnit[ingredientId]![unit] = ingredientsByUnit[ingredientId]![unit]! + amount;
      }
    }

    // Ingredients section
    if (ingredientsByUnit.isNotEmpty) {
      markdown.writeln("## Ingredients");
      markdown.writeln();

      ingredientsByUnit.forEach((String ingredientId, Map<String, double> unitAmounts) {
        final String ingredientName = IngredientsProvider.instance.get(ingredientId).name;
        final List<String> amounts = unitAmounts.entries.map((entry) {
          final double amount = entry.value;
          final String unit = entry.key;
          return "$amount $unit";
        }).toList();

        markdown.writeln("- $ingredientName: ${amounts.join(' + ')}");
      });

      markdown.writeln();
    }

    // Instructions section
    if (widget.recipe.instructions.isNotEmpty) {
      markdown.writeln("## Instructions");
      markdown.writeln();

      for (int i = 0; i < widget.recipe.instructions.length; i++) {
        final Instruction instruction = widget.recipe.instructions[i];
        markdown.writeln("### Step ${i + 1}");
        markdown.writeln();

        markdown.writeln(instruction.description);
        markdown.writeln();

        // Step-specific ingredients
        if (instruction.ingredientsUsed.isNotEmpty) {
          markdown.writeln("**Ingredients for this step:**");
          for (final IngredientUsage usage in instruction.ingredientsUsed) {
            final String ingredientName = IngredientsProvider.instance.get(usage.ingredient).name;
            final double amount = usage.quantity.amount * servings;
            final String unit = usage.quantity.unit.name;
            markdown.writeln("- $ingredientName: $amount $unit");
          }
          markdown.writeln();
        }

        // Time information for the step
        if (instruction.workingTimeMinutes > 0 || instruction.cookingTimeMinutes > 0) {
          markdown.writeln("**Time:**");
          if (instruction.workingTimeMinutes > 0) {
            markdown.writeln("- Working: ${instruction.workingTimeMinutes} minutes");
          }
          if (instruction.cookingTimeMinutes > 0) {
            markdown.writeln("- Cooking: ${instruction.cookingTimeMinutes} minutes");
          }
          markdown.writeln();
        }

        // Inputs
        if (instruction.inputs.isNotEmpty) {
          markdown.writeln("**Inputs from previous steps:**");
          for (final String input in instruction.inputs) {
            markdown.writeln("- $input");
          }
          markdown.writeln();
        }

        // Outputs
        if (instruction.outputs.isNotEmpty) {
          markdown.writeln("**Outputs:**");
          for (final result in instruction.outputs) {
            markdown.writeln("- ${result.description}");
          }
          markdown.writeln();
        }
      }
    }

    return markdown.toString();
  }

  void _exportToClipboard() {
    final int? servings = int.tryParse(servingsController.text);
    if (servings == null || servings <= 0) {
      return;
    }

    final String markdown = _generateMarkdown(servings: servings);
    Clipboard.setData(ClipboardData(text: markdown));

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Recipe exported to clipboard as markdown")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Export Recipe to Markdown"),
      content: TextField(
        controller: servingsController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "Number of Servings",
          helperText: "Ingredient amounts will be scaled accordingly",
        ),
        onChanged: (String value) => setState(() {}),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        FilledButton.icon(
          icon: const Icon(Icons.copy_rounded),
          onPressed: servingsController.text.trimAndSetNullIfEmpty == null || (int.tryParse(servingsController.text) ?? 0) <= 0
              ? null
              : _exportToClipboard,
          label: const Text("Copy"),
        ),
      ],
    );
  }
}
