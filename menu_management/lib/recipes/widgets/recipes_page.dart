import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/widgets/recipe_addition.dart";
import "package:menu_management/recipes/widgets/recipe_page.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:menu_management/recipes/widgets/recipe_title_editor.dart";

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  String? selectedRecipeId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedRecipeId == null
              ? "Recipes"
              : getProvider<RecipesProvider>(context, listen: true).recipes.firstWhere((element) => element.id == selectedRecipeId).name,
        ),
        actions: [
          if (selectedRecipeId != null)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () => RecipeTitleEditor.show(
                context: context,
                recipe: RecipesProvider.instance.get(selectedRecipeId!),
                onUpdate: (Recipe newRecipe) {
                  RecipesProvider.addOrUpdate(newRecipe: newRecipe);
                },
              ),
            ),
          if (selectedRecipeId != null) IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(() => selectedRecipeId = null)),
        ],
      ),
      body: Builder(
        builder: (context) {
          RecipesProvider recipesProvider = getProvider<RecipesProvider>(context, listen: true);

          if (selectedRecipeId != null) {
            return RecipePage(recipeId: selectedRecipeId!);
          }

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
                    selectedRecipeId = recipesProvider.recipes[index].id;
                  });
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${recipesProvider.recipes[index].totalTimeMinutes} min"),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        Recipe toRemove = recipesProvider.recipes[index];
                        RecipesProvider.remove(recipeId: toRemove.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Recipe "${toRemove.name}" removed'),
                            action: SnackBarAction(
                              label: "Undo",
                              onPressed: () {
                                RecipesProvider.addOrUpdate(newRecipe: toRemove);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
