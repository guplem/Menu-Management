import "package:flutter/material.dart";
import "package:menu_management/flutter_essentials/library.dart";
import "package:menu_management/menu/enums/meal_type.dart";
import "package:menu_management/menu/enums/week_day.dart";
import "package:menu_management/menu/menu_dates.dart";
import "package:menu_management/menu/menu_provider.dart";
import "package:menu_management/menu/models/menu_configuration.dart";
import "package:menu_management/menu/models/multi_week_menu.dart";
import "package:menu_management/menu/widgets/menu_page.dart";
import "package:menu_management/persistency.dart";
import "package:menu_management/recipes/recipes_provider.dart";

class MenuConfigurationPage extends StatelessWidget {
  const MenuConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The page borrows the date of the active menu. Read it once: it is the same for every column.
    final DateTime? startDate = MenuProvider.listenableMultiWeekMenuOf(context)?.startDate;
    final WidgetStateProperty<Icon?> switchIcon = WidgetStateProperty.resolveWith<Icon?>((states) {
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
              (LoadOutcome, MultiWeekMenu?) result = await Persistency.loadMultiWeekMenu(recipes: RecipesProvider.instance.recipes);
              if (result.$1 == LoadOutcome.failed && context.mounted) {
                await showErrorDialog(context: context, message: "Could not load the menu. It may be corrupted or not a valid menu file (.tsm).");
              }
              MultiWeekMenu? loadedMenu = result.$2;
              if (loadedMenu != null && context.mounted) {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MenuPage(multiWeekMenu: loadedMenu)));
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Generate Menu",
        child: const Icon(Icons.auto_awesome_sharp),
        onPressed: () {
          MultiWeekMenu multiWeekMenu = MenuProvider.generateMenu(
            initialSeed: DateTime.now().millisecondsSinceEpoch,
            recipes: RecipesProvider.instance.recipes,
          );
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => MenuPage(multiWeekMenu: multiWeekMenu)));
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
                    child: Text(menuDayName(startDate: startDate, dayOffset: weekDayValue)),
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
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium!.copyWith(color: menuConfiguration.requiresMeal ? null : Theme.of(context).colorScheme.outline),
                            child: Text(MealType.fromValue(mealTypeValue).name.capitalizeFirstLetter() ?? "null"),
                          ),
                          const SizedBox(height: 5),
                          Switch(
                            thumbIcon: switchIcon,
                            value: menuConfiguration.requiresMeal,
                            onChanged: (requiredMeal) {
                              MenuProvider.update(newConfiguration: menuConfiguration.copyWith(requiresMeal: requiredMeal));
                            },
                          ),
                          const SizedBox(height: 5),
                          SizedBox(
                            width: 140,
                            child: _CookingTimeField(
                              enabled: menuConfiguration.requiresMeal,
                              minutes: menuConfiguration.availableCookingTimeMinutes,
                              onMinutesChanged: (int cookingTimeMinutes) {
                                MenuProvider.update(newConfiguration: menuConfiguration.copyWith(availableCookingTimeMinutes: cookingTimeMinutes));
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.restaurant_menu, size: 16),
                              const SizedBox(width: 4),
                              Text("Meals: ${menuConfiguration.mealCount}", style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.remove, size: 16),
                                visualDensity: VisualDensity.compact,
                                onPressed: menuConfiguration.mealCount <= 1 || !menuConfiguration.requiresMeal
                                    ? null
                                    : () {
                                        MenuProvider.update(newConfiguration: menuConfiguration.copyWith(mealCount: menuConfiguration.mealCount - 1));
                                      },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                visualDensity: VisualDensity.compact,
                                onPressed: !menuConfiguration.requiresMeal
                                    ? null
                                    : () {
                                        MenuProvider.update(newConfiguration: menuConfiguration.copyWith(mealCount: menuConfiguration.mealCount + 1));
                                      },
                              ),
                            ],
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

/// The "Cooking time" input of one meal slot.
///
/// The field keeps its own controller, so the text that the user types stays on screen. Each valid
/// keystroke stores a value, and the provider then builds the page again. A controller made from the
/// stored value on each build would replace "120/1" with "120", and the next "0" would give "1200".
class _CookingTimeField extends StatefulWidget {
  const _CookingTimeField({required this.enabled, required this.minutes, required this.onMinutesChanged});

  final bool enabled;
  final int minutes;
  final void Function(int minutes) onMinutesChanged;

  @override
  State<_CookingTimeField> createState() => _CookingTimeFieldState();
}

class _CookingTimeFieldState extends State<_CookingTimeField> {
  late final TextEditingController _controller = TextEditingController(text: widget.minutes.toString());

  @override
  void didUpdateWidget(_CookingTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Replace the text only when the stored minutes changed and the text means another value,
    // for example after a menu load.
    if (widget.minutes != oldWidget.minutes && evaluateWholeArithmetic(_controller.text) != widget.minutes) {
      _controller.text = widget.minutes.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      enabled: widget.enabled,
      controller: _controller,
      decoration: const InputDecoration(border: OutlineInputBorder(), labelText: "Cooking time", suffixText: "min"),
      keyboardType: TextInputType.number,
      inputFormatters: [InputFormat.arithmetic],
      onChanged: (String cookingTimeInput) {
        int? cookingTimeMinutes = evaluateWholeArithmetic(cookingTimeInput);
        if (cookingTimeMinutes != null && cookingTimeMinutes >= 0) widget.onMinutesChanged(cookingTimeMinutes);
      },
    );
  }
}
