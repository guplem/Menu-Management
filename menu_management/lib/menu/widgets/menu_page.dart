import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/menu/enums/week_day.dart';
import 'package:menu_management/menu/models/meal.dart';
import 'package:menu_management/menu/models/menu.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key, required this.menu});
  final Menu menu;

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
          // TODO: save the menu to a file
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
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleLarge!,
                    child: Text(WeekDay.fromValue(weekDayValue).name.capitalizeFirstLetter() ?? "null"),
                  ),
                ),
                ...menu.mealsOfDay(WeekDay.fromValue(weekDayValue)).map((Meal meal) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DefaultTextStyle(
                            style: Theme.of(context).textTheme.titleMedium!,
                            // ignore: prefer_interpolation_to_compose_strings
                            child: Text((meal.mealTime.mealType.name.capitalizeFirstLetter() ?? "null") + " (${meal.cookings.length})"),
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
