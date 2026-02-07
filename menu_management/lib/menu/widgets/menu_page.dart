import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_provider.dart";
import "package:menu_management/menu/models/meal.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/persistency.dart";
import "package:menu_management/recipes/models/recipe.dart";
import "package:menu_management/recipes/recipes_provider.dart";
import "package:menu_management/shopping/shopping_page.dart";

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.menu});
  final Menu menu;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  Meal? highlightedMeal;
  late Menu menu;

  @override
  void initState() {
    super.initState();
    menu = widget.menu;
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
                  menu = MenuProvider.generateMenu(initialSeed: DateTime.now().millisecondsSinceEpoch);
                });
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Create Shopping List",
            icon: const Icon(Icons.shopping_basket_rounded),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ShoppingPage(menu: menu)));
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
              // Turn the menu into a string
              final String menuString = menu.toStringBeautified();
              // Copy the string to the clipboard
              Clipboard.setData(ClipboardData(text: menuString));
            },
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            tooltip: "Save Menu",
            child: const Icon(Icons.save_rounded),
            onPressed: () {
              Persistency.saveMenu(menu);
            },
          ),
        ],
      ),
      body: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, weekDayValue) {
          return Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleLarge!,
                    child: Text(WeekDay.fromValue(weekDayValue).name.capitalizeFirstLetter() ?? "null"),
                  ),
                ),
                ...menu.mealsOfDay(WeekDay.fromValue(weekDayValue)).map((Meal? meal) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MouseRegion(
                      onHover: (event) {
                        setState(() {
                          highlightedMeal = meal;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          highlightedMeal = null;
                        });
                      },
                      child: meal == null
                          ? const OutlinedCard(child: SizedBox(height: 50, width: 140))
                          : OutlinedCard(
                              borderColor: highlightedMeal?.cooking?.recipe == meal.cooking?.recipe && meal.cooking != null
                                  ? Theme.of(context).colorScheme.secondaryContainer
                                  : null,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (highlightedMeal == meal)
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_rounded),
                                          onPressed: () async {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text("Select a new recipe"),
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
                                                                menu = menu.copyWithUpdatedRecipe(mealTime: meal.mealTime, recipe: recipe);
                                                              });
                                                              Navigator.of(context).pop();
                                                            },
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(context).pop()),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  DefaultTextStyle(
                                    style: Theme.of(context).textTheme.titleMedium!,
                                    child: Text((meal.mealTime.mealType.name.capitalizeFirstLetter() ?? "null")),
                                  ),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: 140,
                                    child: meal.cooking == null
                                        ? const Icon(Icons.warning_rounded)
                                        : Text(
                                            "(${meal.cooking?.yield}) ${meal.cooking?.recipe.name}",
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                          ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
