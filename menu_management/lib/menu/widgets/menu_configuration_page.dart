import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_provider.dart";
import "package:menu_management/menu/models/menu.dart";
import "package:menu_management/menu/models/menu_configuration.dart";
import "package:menu_management/menu/widgets/menu_page.dart";
import "package:menu_management/persistency.dart";

class MenuConfigurationPage extends StatelessWidget {
  const MenuConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final WidgetStateProperty<Icon?> switchIcon =
        WidgetStateProperty.resolveWith<Icon?>((states) {
          if (states.contains(WidgetState.selected)) {
            return const Icon(Icons.fastfood_rounded);
          }
          return const Icon(Icons.close);
        });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Configuration"),
        actions: [
          IconButton(
            tooltip: "Open Menu",
            icon: const Icon(Icons.file_open),
            onPressed: () async {
              Menu? loadedMenu = await Persistency.loadMenu();
              if (loadedMenu != null && context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => MenuPage(menu: loadedMenu),
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Generate Menu",
        child: const Icon(Icons.auto_awesome_sharp),
        onPressed: () {
          // TODO: pass a random seed to generate a random menu
          Menu menu = MenuProvider.generateMenu(initialSeed: 1);
          // Navigate to MenuPage
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => MenuPage(menu: menu)));
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: DefaultTextStyle(
                    style: Theme.of(context).textTheme.titleLarge!,
                    child: Text(
                      WeekDay.fromValue(
                            weekDayValue,
                          ).name.capitalizeFirstLetter() ??
                          "null",
                    ),
                  ),
                ),
                ...List.generate(3, (mealTypeValue) {
                  MenuConfiguration menuConfiguration =
                      MenuProvider.listenableOf(
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
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(
                                  color: menuConfiguration.requiresMeal
                                      ? null
                                      : Theme.of(context).colorScheme.outline,
                                ),
                            child: Text(
                              MealType.fromValue(
                                    mealTypeValue,
                                  ).name.capitalizeFirstLetter() ??
                                  "null",
                            ),
                          ),
                          const SizedBox(height: 5),
                          Switch(
                            thumbIcon: switchIcon,
                            value: menuConfiguration.requiresMeal,
                            onChanged: (requiredMeal) {
                              menuConfiguration
                                  .copyWith(requiresMeal: requiredMeal)
                                  .saveToProvider();
                            },
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 140,
                            child: TextField(
                              enabled: menuConfiguration.requiresMeal,
                              controller: TextEditingController.fromValue(
                                TextEditingValue(
                                  text: menuConfiguration
                                      .availableCookingTimeMinutes
                                      .toString(),
                                  selection: TextSelection.collapsed(
                                    offset: menuConfiguration
                                        .availableCookingTimeMinutes
                                        .toString()
                                        .length,
                                  ),
                                ),
                              ),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Cooking time",
                                suffixText: "min",
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (String cookingTimeInput) {
                                int? cookingTimeMinutes = int.tryParse(
                                  cookingTimeInput,
                                );
                                if (cookingTimeMinutes != null) {
                                  menuConfiguration
                                      .copyWith(
                                        availableCookingTimeMinutes:
                                            cookingTimeMinutes,
                                      )
                                      .saveToProvider();
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
