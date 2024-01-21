import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/menu/enums/week_day.dart';
import 'package:menu_management/menu/models/meal.dart';
import 'package:menu_management/menu/models/menu.dart';
import 'package:menu_management/persistency.dart';
import 'package:menu_management/recipes/models/recipe.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key, required this.menu});
  final Menu menu;

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {

  Recipe? highlightedRecipe;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Save Menu",
        child: const Icon(Icons.save_rounded),
        onPressed: () {
          Persistency.saveMenu(widget.menu);
        },
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
                ...widget.menu.mealsOfDay(WeekDay.fromValue(weekDayValue)).map((Meal meal) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MouseRegion(
                      onHover: (event) {
                        setState(() {
                          highlightedRecipe = meal.cookings.firstOrNull?.recipe;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          highlightedRecipe = null;
                        });
                      },
                      child: OutlinedCard(
                        borderColor: highlightedRecipe == meal.cookings.firstOrNull?.recipe && meal.cookings.firstOrNull != null ? Theme.of(context).colorScheme.secondaryContainer : null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DefaultTextStyle(
                              style: Theme.of(context).textTheme.titleMedium!,
                              child: Text((meal.mealTime.mealType.name.capitalizeFirstLetter() ?? "null") ),
                            ),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 140,
                              child: Column(
                                children: [
                                  ...meal.cookings.map((cooking) {
                                    return Text(
                                      "(${cooking.yield}) ${cooking.recipe.name}",
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    );
                                  }),
                                ],
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
