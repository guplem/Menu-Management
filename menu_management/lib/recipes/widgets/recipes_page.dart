import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/menu_dates.dart";
import "package:menu_management/menu/menu_provider.dart";
import "package:menu_management/menu/models/meal_time.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:menu_management/recipes/widgets/export_recipe_to_markdown.dart";
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

  void playRecipe() {
    final Recipe recipe = RecipesProvider.instance.get(selectedRecipeId!);
    if (recipe.instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Add at least one step before cooking this recipe.")));
      return;
    }
    PlayRecipePage.show(context: context, recipe: recipe);
  }

  /// Names one meal slot of the menu, such as "Week 1 - Saturday lunch".
  /// With a menu start date the day also carries its real date, such as "Week 1 - Wednesday 6 Aug lunch".
  String _mealSlotLabel(({int weekIndex, MealTime mealTime}) reference, {required DateTime? startDate}) {
    String day = menuDayLabel(startDate: startDate, weekIndex: reference.weekIndex, weekDay: reference.mealTime.weekDay);
    return "Week ${reference.weekIndex + 1} - $day ${reference.mealTime.mealType.name}";
  }

  Future<void> _deleteSelectedRecipe() async {
    final Recipe toRemove = RecipesProvider.instance.get(selectedRecipeId!);
    final MultiWeekMenu? menu = MenuProvider.instance.multiWeekMenu;
    final List<({int weekIndex, MealTime mealTime})> referencingMeals = menu?.findReferencingMeals(toRemove.id) ?? [];
    // A meal can only reference the recipe when a menu exists, so both steps share one branch.
    if (menu != null && referencingMeals.isNotEmpty) {
      bool confirmed = await showDeleteConfirmationDialog(
        context: context,
        title: 'Delete recipe "${toRemove.name}"?',
        message: "It is planned in the current menu. Deleting it will clear these meal slots:",
        affectedItems: referencingMeals
            .map((({int weekIndex, MealTime mealTime}) reference) => _mealSlotLabel(reference, startDate: menu.startDate))
            .toList(),
      );
      if (!confirmed || !context.mounted) return;
      MenuProvider.setMultiWeekMenu(menu.copyWithClearedRecipe(recipeId: toRemove.id, recipes: RecipesProvider.instance.recipes));
    }
    RecipesProvider.remove(recipeId: toRemove.id);
    selectedRecipeId = null;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Recipe "${toRemove.name}" removed'),
        persist: false,
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            RecipesProvider.addOrUpdate(newRecipe: toRemove);
            if (referencingMeals.isNotEmpty && menu != null) {
              MenuProvider.setMultiWeekMenu(menu);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedRecipeId != null)
              IconButton(onPressed: () => setState(() => selectedRecipeId = null), icon: const Icon(Icons.arrow_back_rounded)),
            Gap.horizontal(),
            Text(
              selectedRecipeId == null
                  ? "Recipes"
                  : getProvider<RecipesProvider>(context, listen: true).recipes.firstWhere((element) => element.id == selectedRecipeId).name,
            ),
            Gap.horizontal(),
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
          ],
        ),
        actions: [
          if (selectedRecipeId != null) ...[
            TextButton.icon(icon: const Icon(Icons.delete_rounded), label: const Text("Delete"), onPressed: _deleteSelectedRecipe),
            Gap.horizontal(),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy_rounded),
              label: const Text("Export Markdown"),
              onPressed: () {
                ExportRecipeToMarkdown.show(context: context, recipe: RecipesProvider.instance.get(selectedRecipeId!));
              },
            ),
            Gap.horizontal(),
          ],
        ],
      ),
      floatingActionButton: selectedRecipeId != null
          ? FloatingActionButton.extended(onPressed: playRecipe, icon: const Icon(Icons.play_arrow_rounded), label: const Text("Cook"))
          : null,
      body: Builder(
        builder: (context) {
          RecipesProvider recipesProvider = getProvider<RecipesProvider>(context, listen: true);

          if (selectedRecipeId != null) {
            return RecipePage(recipeId: selectedRecipeId!);
          }

          final normalizedSearch = _search.normalizeForSearch(removeSpaces: true);
          final filtered =
              (normalizedSearch.isEmpty
                      ? recipesProvider.recipes
                      : recipesProvider.recipes.where((r) => r.name.normalizeForSearch(removeSpaces: true).contains(normalizedSearch)))
                  .sorted((Recipe a, Recipe b) => a.name.normalizeForSearch().compareTo(b.name.normalizeForSearch()))
                  .toList();

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
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${filtered[index].totalTimeMinutes} min"),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          selectedRecipeId = filtered[index].id;
                        });
                        playRecipe();
                      },
                      icon: const Icon(Icons.play_arrow_rounded),
                      tooltip: "Cook",
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
