import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_provider.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/models/sub_meal.dart";
import "package:menu_management/persistency.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:menu_management/recipes/widgets/play_recipe_page.dart";
import "package:menu_management/shopping/shopping_page.dart";
import "package:menu_management/theme/theme_custom.dart";

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.multiWeekMenu});
  final MultiWeekMenu multiWeekMenu;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  String? highlightedRecipeId;
  late MultiWeekMenu multiWeekMenu;
  int currentWeekIndex = 0;

  @override
  void initState() {
    super.initState();
    multiWeekMenu = widget.multiWeekMenu;
  }

  List<Recipe> get _recipes => RecipesProvider.instance.recipes;

  Menu get currentWeek => multiWeekMenu.weeks[currentWeekIndex];

  void _addWeek() {
    setState(() {
      Menu newWeek = MenuProvider.generateAdditionalWeek(seed: DateTime.now().millisecondsSinceEpoch, recipes: RecipesProvider.instance.recipes);
      multiWeekMenu = multiWeekMenu.addWeek(newWeek);
      currentWeekIndex = multiWeekMenu.weekCount - 1;
    });
  }

  void _removeLastWeek() {
    if (multiWeekMenu.weekCount <= 1) return;
    setState(() {
      multiWeekMenu = multiWeekMenu.removeLastWeek();
      if (currentWeekIndex >= multiWeekMenu.weekCount) {
        currentWeekIndex = multiWeekMenu.weekCount - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text("Menu"),
            IconButton(
              tooltip: "Regenerate Menu",
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                setState(() {
                  MultiWeekMenu regenerated = MenuProvider.generateMenu(
                    initialSeed: DateTime.now().millisecondsSinceEpoch,
                    recipes: RecipesProvider.instance.recipes,
                  );
                  multiWeekMenu = regenerated;
                  currentWeekIndex = 0;
                });
              },
            ),
            const SizedBox(width: 16),
            _buildWeekNavigator(),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Create Shopping List",
            icon: const Icon(Icons.shopping_basket_rounded),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShoppingPage(multiWeekMenu: multiWeekMenu)));
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            tooltip: "Copy to clipboard",
            child: const Icon(Icons.copy_rounded),
            onPressed: () {
              final String menuString = multiWeekMenu.toStringBeautified(recipes: _recipes);
              Clipboard.setData(ClipboardData(text: menuString));
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            tooltip: "Save Menu",
            child: const Icon(Icons.save_rounded),
            onPressed: () {
              Persistency.saveMenu(multiWeekMenu, recipes: _recipes);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double columnWidth = constraints.maxWidth / 7;
          return SingleChildScrollView(
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(7, (int weekDayValue) {
                  return SizedBox(
                    width: columnWidth,
                    child: Card(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(15),
                            child: DefaultTextStyle(
                              style: Theme.of(context).textTheme.titleLarge!,
                              child: Text(WeekDay.fromValue(weekDayValue).name.capitalizeFirstLetter() ?? "null"),
                            ),
                          ),
                          ...currentWeek.mealsOfDay(WeekDay.fromValue(weekDayValue)).map((Meal? meal) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: meal == null
                                  ? const OutlinedCard(child: SizedBox(height: 50, width: 140))
                                  : _buildMealCard(meal),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return OutlinedCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.titleMedium!,
              child: Text(meal.mealTime.mealType.name.capitalizeFirstLetter() ?? "null"),
            ),
          ),
          if (meal.subMeals.isEmpty)
            const SizedBox(height: 50, width: 140)
          else
            ...meal.subMeals.asMap().entries.map((MapEntry<int, SubMeal> entry) {
              int subMealIndex = entry.key;
              SubMeal subMeal = entry.value;
              return _buildSubMealSection(meal, subMealIndex, subMeal);
            }),
          IconButton(
            icon: const Icon(Icons.add, size: 16),
            tooltip: "Add sub-meal",
            visualDensity: VisualDensity.compact,
            onPressed: () => setState(() {
              Menu updatedWeek = currentWeek.copyWithAddedSubMeal(mealTime: meal.mealTime, recipes: _recipes);
              multiWeekMenu = multiWeekMenu.updateWeekAt(currentWeekIndex, updatedWeek).copyWithUpdatedYields(recipes: _recipes);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMealSection(Meal meal, int subMealIndex, SubMeal subMeal) {
    Recipe? recipe = subMeal.cooking != null ? _recipes.firstWhereOrNull((r) => r.id == subMeal.cooking!.recipeId) : null;
    bool isHighlighted = highlightedRecipeId != null && subMeal.cooking?.recipeId == highlightedRecipeId;

    return MouseRegion(
      onHover: (_) {
        if (subMeal.cooking != null) {
          setState(() => highlightedRecipeId = subMeal.cooking!.recipeId);
        }
      },
      onExit: (_) => setState(() => highlightedRecipeId = null),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: isHighlighted ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => _showRecipePicker(meal, subMealIndex),
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 140,
                child: subMeal.cooking == null
                    ? const SizedBox(height: 30, child: Center(child: Text("-", style: TextStyle(color: Colors.grey))))
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            recipe?.name ?? "?",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: subMeal.cooking!.yield == 0
                              ? Chip(
                                  label: const Text("Leftovers"),
                                  backgroundColor: ThemeCustom.colorScheme(context).primaryContainer,
                                  labelStyle: TextStyle(
                                    color: ThemeCustom.colorScheme(context).onPrimaryContainer,
                                    fontSize: 12,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                )
                              : ActionChip(
                                  label: Text(
                                    "Cook ${multiWeekMenu.servingsForCookEvent(cookWeekIndex: currentWeekIndex, cookMealTime: meal.mealTime, subMealIndex: subMealIndex, recipes: _recipes)} servings",
                                  ),
                                  backgroundColor: ThemeCustom.colorScheme(context).tertiaryContainer,
                                  labelStyle: TextStyle(
                                    color: ThemeCustom.colorScheme(context).onTertiaryContainer,
                                    fontSize: 12,
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    if (recipe != null) {
                                      PlayRecipePage.show(
                                        context: context,
                                        recipe: recipe,
                                        initialServings: multiWeekMenu.servingsForCookEvent(
                                          cookWeekIndex: currentWeekIndex,
                                          cookMealTime: meal.mealTime,
                                          subMealIndex: subMealIndex,
                                          recipes: _recipes,
                                        ),
                                      );
                                    }
                                  },
                                ),
                          ),
                        ],
                      ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: subMeal.people <= 0
                      ? null
                      : () => setState(() {
                          Menu updatedWeek = currentWeek.copyWithUpdatedPeople(
                            mealTime: meal.mealTime,
                            subMealIndex: subMealIndex,
                            people: subMeal.people - 1,
                            recipes: _recipes,
                          );
                          multiWeekMenu = multiWeekMenu.updateWeekAt(currentWeekIndex, updatedWeek).copyWithUpdatedYields(recipes: _recipes);
                        }),
                ),
                Text("${subMeal.people}"),
                const SizedBox(width: 4),
                Icon(
                  subMeal.people <= 0
                      ? Icons.person_outline_rounded
                      : subMeal.people <= 1
                          ? Icons.person_rounded
                          : Icons.people_alt_rounded,
                  size: 18,
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 18),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => setState(() {
                    Menu updatedWeek = currentWeek.copyWithUpdatedPeople(
                      mealTime: meal.mealTime,
                      subMealIndex: subMealIndex,
                      people: subMeal.people + 1,
                      recipes: _recipes,
                    );
                    multiWeekMenu = multiWeekMenu.updateWeekAt(currentWeekIndex, updatedWeek).copyWithUpdatedYields(recipes: _recipes);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipePicker(Meal meal, int subMealIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(meal.subMeals.length > 1 ? "Select recipe (slot ${subMealIndex + 1})" : "Select a new recipe"),
          content: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: RecipesProvider.instance.recipes.map((Recipe recipe) {
                  return ListTile(
                    title: Text(recipe.name),
                    onTap: () {
                      setState(() {
                        Menu updatedWeek = currentWeek.copyWithUpdatedRecipe(
                          mealTime: meal.mealTime,
                          subMealIndex: subMealIndex,
                          recipe: recipe,
                          recipes: _recipes,
                        );
                        multiWeekMenu = multiWeekMenu.updateWeekAt(currentWeekIndex, updatedWeek).copyWithUpdatedYields(recipes: _recipes);
                      });
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(meal.subMeals.length > 1 ? "Remove sub-meal" : "Remove recipe"),
              onPressed: () {
                setState(() {
                  Menu updatedWeek = meal.subMeals.length > 1
                      ? currentWeek.copyWithRemovedSubMeal(
                          mealTime: meal.mealTime,
                          subMealIndex: subMealIndex,
                          recipes: _recipes,
                        )
                      : currentWeek.copyWithClearedSubMeal(
                          mealTime: meal.mealTime,
                          subMealIndex: subMealIndex,
                          recipes: _recipes,
                        );
                  multiWeekMenu = multiWeekMenu.updateWeekAt(currentWeekIndex, updatedWeek).copyWithUpdatedYields(recipes: _recipes);
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  Widget _buildWeekNavigator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: "Remove last week",
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: multiWeekMenu.weekCount <= 1 ? null : _removeLastWeek,
        ),
        if (multiWeekMenu.weekCount > 1) ...[
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: currentWeekIndex > 0 ? () => setState(() => currentWeekIndex--) : null),
          Text("Week ${currentWeekIndex + 1} / ${multiWeekMenu.weekCount}", style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentWeekIndex < multiWeekMenu.weekCount - 1 ? () => setState(() => currentWeekIndex++) : null,
          ),
        ],
        IconButton(tooltip: "Add another week", icon: const Icon(Icons.add_circle_outline), onPressed: _addWeek),
      ],
    );
  }
}
