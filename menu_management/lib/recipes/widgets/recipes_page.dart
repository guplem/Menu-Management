import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:menu_management/recipes/widgets/play_recipe_page.dart";
import "package:menu_management/recipes/widgets/recipe_addition.dart";
import "package:menu_management/recipes/widgets/recipe_page.dart";
import "package:menu_management/recipes/widgets/recipe_title_editor.dart";

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  String? selectedRecipeId;
  String _search = "";

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
      floatingActionButton: selectedRecipeId != null
          ? FloatingActionButton.extended(
              onPressed: () {
                final Recipe recipe = RecipesProvider.instance.get(selectedRecipeId!);
                if (recipe.instructions.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add at least one step before cooking this recipe.")));
                  return;
                }
                PlayRecipePage.show(context: context, recipe: recipe);
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text("Cook"),
            )
          : null,
      body: Builder(
        builder: (context) {
          RecipesProvider recipesProvider = getProvider<RecipesProvider>(context, listen: true);

          if (selectedRecipeId != null) {
            return RecipePage(recipeId: selectedRecipeId!);
          }

          final filtered = _search.trim().isEmpty
              ? recipesProvider.recipes
              : recipesProvider.recipes.where((r) => r.name.toLowerCase().contains(_search.trim().toLowerCase())).toList();

          return ListView.builder(
            itemCount: filtered.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return RecipeAddition(onUpdate: (value) => setState(() => _search = value));
              }

              index--;

              return ListTile(
                title: Text(filtered[index].name),
                onTap: () {
                  setState(() {
                    selectedRecipeId = filtered[index].id;
                  });
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${filtered[index].totalTimeMinutes} min"),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        Recipe toRemove = filtered[index];
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
