import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/menu/enums/meal_type.dart';
import 'package:menu_management/menu/enums/week_day.dart';
import 'package:menu_management/menu/menu_provider.dart';
import 'package:menu_management/menu/models/menu_configuration.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialStateProperty<Icon?> switchIcon = MaterialStateProperty.resolveWith<Icon?>((states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.fastfood_rounded);
      }
      return const Icon(Icons.close);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            tooltip: "Open Menu",
            icon: const Icon(Icons.file_open),
            onPressed: () {
              // TODO: Load menu from file and open menu visualization page
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Generate Menu",
        child: const Icon(Icons.auto_awesome_sharp),
        onPressed: () {
          // TODO: Trigger menu generation and open menu visualization page
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
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleLarge!,
                    child: Builder(builder: (context) {
                      switch (weekDayValue) {
                        case 0:
                          return const Text('Saturday');
                        case 1:
                          return const Text('Sunday');
                        case 2:
                          return const Text('Monday');
                        case 3:
                          return const Text('Tuesday');
                        case 4:
                          return const Text('Wednesday');
                        case 5:
                          return const Text('Thursday');
                        case 6:
                          return const Text('Friday');
                        default:
                          return const Text('Error');
                      }
                    }),
                  ),
                ),
                ...List.generate(3, (mealTypeValue) {
                  MenuConfiguration menuConfiguration = MenuProvider.listenableOf(
                    context,
                    weekDay: WeekDay.fromValue(weekDayValue),
                    mealType: MealType.fromValue(mealTypeValue),
                  );

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedCard(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DefaultTextStyle(
                            style: Theme.of(context).textTheme.titleMedium!,
                            child: Builder(
                              builder: (context) {
                                switch (mealTypeValue) {
                                  case 0:
                                    return const Text('Breakfast');
                                  case 1:
                                    return const Text('Lunch');
                                  case 2:
                                    return const Text('Dinner');
                                  default:
                                    return const Text('Error');
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                          Switch(
                            thumbIcon: switchIcon,
                            value: menuConfiguration.requiresMeal,
                            onChanged: (requiredMeal) {
                              menuConfiguration.copyWith(requiresMeal: requiredMeal).saveToProvider();
                            },
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 140,
                            child: TextField(
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: menuConfiguration.availableCookingTimeMinutes.toString(),
                                  selection: TextSelection.collapsed(
                                    offset: menuConfiguration.availableCookingTimeMinutes.toString().length,
                                  ),
                                ),
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Cooking time',
                                suffixText: "min",
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: (String cookingTimeInput) {
                                int? cookingTimeMinutes = int.tryParse(cookingTimeInput);
                                if (cookingTimeMinutes != null) {
                                  menuConfiguration.copyWith(availableCookingTimeMinutes: cookingTimeMinutes).saveToProvider();
                                }
                              },
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
