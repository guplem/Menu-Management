import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/recipes/models/recipe.dart';
import 'package:menu_management/recipes/widgets/recipe_addition.dart';
import 'package:menu_management/recipes/widgets/recipe_page.dart';
import 'package:menu_management/recipes/recipes_provider.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  Recipe? selectedRecipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(selectedRecipe == null ? 'Recipes' : selectedRecipe!.name),
        ),
        body: Builder(
          builder: (context) {
            if (selectedRecipe != null) {
              return RecipePage(recipe: selectedRecipe!);
            }

            RecipesProvider recipesProvider = getProvider<RecipesProvider>(context, listen: true);
            return ListView.builder(
              itemCount: recipesProvider.recipes.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const RecipeAddition();
                }

                index--;

                return ListTile(
                  title: Text(recipesProvider.recipes[index].name),
                  onTap: () {
                    setState(() {
                      selectedRecipe = recipesProvider.recipes[index];
                    });
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      Recipe toRemove = recipesProvider.recipes[index];
                      recipesProvider.removeRecipe(toRemove);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Recipe "${toRemove.name}" removed'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () {
                              RecipesProvider.instance.addRecipe(toRemove);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ));
  }
}
