import 'package:flutter/material.dart';
import 'package:menu_management/recipes/recipe.dart';

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
    final MaterialStateProperty<Icon?> switchIcon = MaterialStateProperty.resolveWith<Icon?>((states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    });

    return ListView.builder(
      itemCount: newRecipe.steps.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: RecipeConfiguration(),
          );
        }
        return TextFormField(
          initialValue: newRecipe.steps[index - 1].description,
          decoration: const InputDecoration(
            labelText: 'Step',
          ),
          onChanged: (value) {
            newRecipe.steps[index - 1].description = value;
          },
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
              newRecipe.carbs = value;
            });
          },
        ),
        const SizedBox(width: 10),
        FilterChip(
          label: const Text('Protein'),
          selected: newRecipe.proteins,
          onSelected: (value) {
            setState(() {
              newRecipe.proteins = value;
            });
          },
        ),
        const SizedBox(width: 10),
        FilterChip(
          label: const Text('Vegetables'),
          selected: newRecipe.vegetables,
          onSelected: (value) {
            setState(() {
              newRecipe.vegetables = value;
            });
          },
        ),
      ],
    );
  }
}
