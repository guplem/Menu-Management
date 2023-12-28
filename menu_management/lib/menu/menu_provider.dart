import 'dart:math';
import 'package:flutter/material.dart';
import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/menu/enums/meal_type.dart';
import 'package:menu_management/menu/enums/week_day.dart';
import 'package:menu_management/menu/models/cooking.dart';
import 'package:menu_management/menu/models/menu.dart';
import 'package:menu_management/menu/models/menu_configuration.dart';
import 'package:menu_management/menu/models/meal_time.dart';
import 'package:menu_management/recipes/enums/recipe_type.dart';
import 'package:menu_management/recipes/models/recipe.dart';
import 'package:menu_management/recipes/recipes_provider.dart';
import 'models/meal.dart';

// Alter data should be done through the static methods.
// Fetching data should be done through the listenableOf method or through the provider in the tree.
class MenuProvider extends ChangeNotifier {

  factory MenuProvider() {
    return instance;
  }

  static final MenuProvider instance = MenuProvider._privateConstructor();
  MenuProvider._privateConstructor(){
    Debug.log("Creating MenuProvider instance", maxStackTraceRows: 4);
  }

  final List<MenuConfiguration> _configurations = [
    // SATURDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.saturday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
    // SUNDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.sunday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.sunday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.sunday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
    // MONDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.monday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
    // TUESDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.tuesday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.tuesday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.tuesday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
    // WEDNESDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.wednesday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.wednesday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.wednesday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
    // THURSDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.thursday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.thursday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.thursday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
    // FRIDAY
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.friday, mealType: MealType.breakfast), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.friday, mealType: MealType.lunch), availableCookingTimeMinutes: 60, requiresMeal: true),
    const MenuConfiguration(mealTime: MealTime(weekDay: WeekDay.friday, mealType: MealType.dinner), availableCookingTimeMinutes: 60, requiresMeal: true),
  ];

  List<MenuConfiguration> get configurations => _configurations;

  static MenuConfiguration listenableOf(context, {required WeekDay weekDay, required MealType mealType}) => getProvider<MenuProvider>(context, listen: true).get(mealType: mealType, weekDay: weekDay);

  MenuConfiguration getConfigurationForMeal(MealTime mealTime) {
    return configurations.firstWhere((MenuConfiguration configuration) => configuration.mealTime.isSameTime(mealTime));
  }

  void setData(List<MenuConfiguration> recipes) {
    _configurations.clear();
    _configurations.addAll(recipes);
    notifyListeners();
  }

  MenuConfiguration get({required WeekDay weekDay, required MealType mealType}) {
    return configurations.firstWhere((element) {
      return element.mealTime.weekDay == weekDay && element.mealTime.mealType == mealType;
    });
  }

  static void update({required MenuConfiguration newConfiguration}) {
    final int index = instance.configurations.indexWhere((element) => element.mealTime.weekDay == newConfiguration.mealTime.weekDay && element.mealTime.mealType == newConfiguration.mealTime.mealType);
    if (index >= 0) {
      instance.configurations[index] = newConfiguration;
      instance.notifyListeners();
    } else {
      Debug.logError("No configuration found for ${newConfiguration.mealTime.weekDay} ${newConfiguration.mealTime.mealType}");
    }
  }

  static Menu generateMenu({required int initialSeed}) {
    // *** SORT ALL MEALS BY TYPE *** //

    List<Recipe> breakfasts = RecipesProvider().getOfType(type: RecipeType.breakfast);
    Debug.logWarning(breakfasts.isEmpty, "No breakfasts found");
    List<Recipe> carbsHeavies = RecipesProvider().getOfType(type: RecipeType.heavy, carbs: true);
    Debug.logWarning(carbsHeavies.isEmpty, "No carbsHeavies found");
    List<Recipe> proteinHeavies = RecipesProvider().getOfType(type: RecipeType.heavy, proteins: true);
    Debug.logWarning(proteinHeavies.isEmpty, "No proteinHeavies found");
    List<Recipe> veggieHeavies = RecipesProvider().getOfType(type: RecipeType.heavy, vegetables: true);
    Debug.logWarning(veggieHeavies.isEmpty, "No veggieHeavies found");
    List<Recipe> carbsLights = RecipesProvider().getOfType(type: RecipeType.light, carbs: true);
    Debug.logWarning(carbsLights.isEmpty, "No carbsLights found");
    List<Recipe> proteinLights = RecipesProvider().getOfType(type: RecipeType.light, proteins: true);
    Debug.logWarning(proteinLights.isEmpty, "No proteinLights found");
    List<Recipe> veggieLights = RecipesProvider().getOfType(type: RecipeType.light, vegetables: true);
    Debug.logWarning(veggieLights.isEmpty, "No veggieLights found");

    // TODO: Decide when to use "snacks" saturdays?
    // ignore: unused_local_variable
    List<Recipe> snacks = RecipesProvider().getOfType(type: RecipeType.snack);

    // TODO: Decide when to use "not vegetable desserts"
    // ignore: unused_local_variable
    List<Recipe> notVegetableDesserts = RecipesProvider().getOfType(type: RecipeType.dessert, vegetables: false);
    // ignore: unused_local_variable
    List<Recipe> fruitDesserts = RecipesProvider().getOfType(type: RecipeType.dessert, vegetables: true);

    // ** helpers ** //
    int seedIncrementTimes = 0;
    int seed() {
      seedIncrementTimes++;
      return initialSeed + seedIncrementTimes;
    }

    // Breakfast
    Recipe? lastBreakfast1;
    Recipe? lastBreakfast2;
    Recipe? lastBreakfast3;
    // Heavy
    Recipe? lastCarbHeavy;
    Recipe? lastVeggieHeavy;
    Recipe? lastProteinHeavy;
    // Light
    Recipe? lastProteinLight1;
    Recipe? lastVeggieLight1;
    Recipe? lastCarbsLight1;
    Recipe? lastProteinLight2;
    Recipe? lastVeggieLight2;
    Recipe? lastCarbsLight2;

    int lastBreakfast = -1; // 1, 2 or 3, 3 total variants of breakfast
    int lastHeavy = -1; // 1, 2 or 3, 3 total variants of heavy meals
    int lastLight = -1; // 1, 2, 3, 4, 5 or 6, 6 total variants of light meals

    Recipe? getRecipeSuggestion({required List<Recipe> candidates, required MenuConfiguration configuration, List<Recipe> otherRecipesOfTheSameMeal = const []}) {
      if (!configuration.requiresMeal) {
        Debug.logError("Configuration does not require a meal, this should never becalled happen");
        return null;
      }

      List<Recipe> randomizedCandidates = [...candidates];
      randomizedCandidates.shuffle(Random(seed()));

      int cookingTimeAlreadyUsed = otherRecipesOfTheSameMeal.fold(0, (previousValue, element) => previousValue + element.cookingTimeMinutes);

      for (Recipe recipe in randomizedCandidates) {
        if (recipe.cookingTimeMinutes <= configuration.availableCookingTimeMinutes - cookingTimeAlreadyUsed) {
          return recipe;
        }
      }

      return null;
    }

    // Prefer heavy meals for lunch
    // Prefer light meals for dinner, unless some of the heavy meals have not been selected
    List<Recipe>? getMealFor({required MenuConfiguration configuration, required int seed}) {
      if (!configuration.requiresMeal) {
        return null;
      }
      List<Recipe>? recipes;
      switch (configuration.mealTime.mealType) {
        case MealType.breakfast:
          // Pick a breakfast number
          int selectedBreakfast = -1;
          if (lastBreakfast1 == null) {
            selectedBreakfast = 1;
          } else if (lastBreakfast2 == null) {
            selectedBreakfast = 2;
          } else if (lastBreakfast3 == null) {
            selectedBreakfast = 3;
          } else {
            if (lastBreakfast == 1) {
              selectedBreakfast = 2;
            } else if (lastBreakfast == 2) {
              selectedBreakfast = 3;
            } else if (lastBreakfast == 3) {
              selectedBreakfast = 1;
            }
          }
          // Pick a recipe
          if (selectedBreakfast == 1) {
            if (lastBreakfast1 != null && lastBreakfast1!.canBeStored) {
              recipes = [lastBreakfast1!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: breakfasts, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastBreakfast1 = recipe;
              lastBreakfast = 1;
              recipes = [lastBreakfast1!];
            }
          } else if (selectedBreakfast == 2) {
            if (lastBreakfast2 != null && lastBreakfast2!.canBeStored) {
              recipes = [lastBreakfast2!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: breakfasts, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastBreakfast2 = recipe;
              lastBreakfast = 2;
              recipes = [lastBreakfast2!];
            }
          } else if (selectedBreakfast == 3) {
            if (lastBreakfast3 != null && lastBreakfast3!.canBeStored) {
              recipes = [lastBreakfast3!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: breakfasts, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastBreakfast3 = recipe;
              lastBreakfast = 3;
              recipes = [lastBreakfast3!];
            }
          }

        case MealType.lunch:
          // Pick a heavy meal number
          int selectedHeavy = -1;
          if (lastCarbHeavy == null) {
            selectedHeavy = 1;
          } else if (lastVeggieHeavy == null) {
            selectedHeavy = 2;
          } else if (lastProteinHeavy == null) {
            selectedHeavy = 3;
          } else {
            if (lastHeavy == 1) {
              selectedHeavy = 2;
            } else if (lastHeavy == 2) {
              selectedHeavy = 3;
            } else if (lastHeavy == 3) {
              selectedHeavy = 1;
            }
          }
          // Pick a recipe
          if (selectedHeavy == 1) {
            if (lastCarbHeavy != null && lastCarbHeavy!.canBeStored) {
              recipes = [lastCarbHeavy!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: carbsHeavies, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastCarbHeavy = recipe;
              lastHeavy = 1;
              recipes = [lastCarbHeavy!];
            }
          } else if (selectedHeavy == 2) {
            if (lastVeggieHeavy != null && lastVeggieHeavy!.canBeStored) {
              recipes = [lastVeggieHeavy!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: veggieHeavies, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastVeggieHeavy = recipe;
              lastHeavy = 2;
              recipes = [lastVeggieHeavy!];
            }
          } else if (selectedHeavy == 3) {
            if (lastProteinHeavy != null && lastProteinHeavy!.canBeStored) {
              recipes = [lastProteinHeavy!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: proteinHeavies, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastProteinHeavy = recipe;
              lastHeavy = 3;
              recipes = [lastProteinHeavy!];
            }
          }

        case MealType.dinner:

          // Before any light meal, first ensure all heavy meals have been selected
          if (lastCarbHeavy == null || lastProteinHeavy == null || lastVeggieHeavy == null) {
            List<Recipe>? r = getMealFor(configuration: configuration.copyWith(mealTime: configuration.mealTime.copyWith(mealType: MealType.lunch)), seed: seed);
            if (r != null) {
              return r;
            }
          }

          // Pick a light meal number
          int selectedLight = -1;
          if (lastProteinLight1 == null) {
            selectedLight = 1;
          } else if (lastVeggieLight1 == null) {
            selectedLight = 2;
          } else if (lastCarbsLight1 == null) {
            selectedLight = 3;
          } else if (lastProteinLight2 == null) {
            selectedLight = 4;
          } else if (lastVeggieLight2 == null) {
            selectedLight = 5;
          } else if (lastCarbsLight2 == null) {
            selectedLight = 6;
          } else {
            if (lastLight == 1) {
              selectedLight = 2;
            } else if (lastLight == 2) {
              selectedLight = 3;
            } else if (lastLight == 3) {
              selectedLight = 4;
            } else if (lastLight == 4) {
              selectedLight = 5;
            } else if (lastLight == 5) {
              selectedLight = 6;
            } else if (lastLight == 6) {
              selectedLight = 1;
            }
          }

          // Pick a recipe
          if (selectedLight == 1) {
            if (lastProteinLight1 != null && lastProteinLight1!.canBeStored) {
              recipes = [lastProteinLight1!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: proteinLights, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastProteinLight1 = recipe;
              lastLight = 1;
              recipes = [lastProteinLight1!];
            }
          } else if (selectedLight == 2) {
            if (lastVeggieLight1 != null && lastVeggieLight1!.canBeStored) {
              recipes = [lastVeggieLight1!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: veggieLights, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastVeggieLight1 = recipe;
              lastLight = 2;
              recipes = [lastVeggieLight1!];
            }
          } else if (selectedLight == 3) {
            if (lastCarbsLight1 != null && lastCarbsLight1!.canBeStored) {
              recipes = [lastCarbsLight1!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: carbsLights, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastCarbsLight1 = recipe;
              lastLight = 3;
              recipes = [lastCarbsLight1!];
            }
          } else if (selectedLight == 4) {
            if (lastProteinLight2 != null && lastProteinLight2!.canBeStored) {
              recipes = [lastProteinLight2!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: proteinLights, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastProteinLight2 = recipe;
              lastLight = 4;
              recipes = [lastProteinLight2!];
            }
          } else if (selectedLight == 5) {
            if (lastVeggieLight2 != null && lastVeggieLight2!.canBeStored) {
              recipes = [lastVeggieLight2!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: veggieLights, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastVeggieLight2 = recipe;
              lastLight = 5;
              recipes = [lastVeggieLight2!];
            }
          } else if (selectedLight == 6) {
            if (lastCarbsLight2 != null && lastCarbsLight2!.canBeStored) {
              recipes = [lastCarbsLight2!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: carbsLights, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastCarbsLight2 = recipe;
              lastLight = 6;
              recipes = [lastCarbsLight2!];
            }
          }
      }

      if (recipes == null) {
        Debug.logError("No recipe found for ${configuration.mealTime.weekDay} ${configuration.mealTime.mealType}");
      }

      // TODO: Populate snacks and desserts, take into account the available cooking time by using the parameter otherRecipesOfTheSameMeal of the method getRecipeSuggestion

      return recipes;
    }

    List<Recipe>? saturdayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.saturday), seed: seed());
    List<Recipe>? saturdayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.saturday), seed: seed());
    List<Recipe>? saturdayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.saturday), seed: seed());

    List<Recipe>? sundayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.sunday), seed: seed());
    List<Recipe>? sundayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.sunday), seed: seed());
    List<Recipe>? sundayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.sunday), seed: seed());

    List<Recipe>? mondayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.monday), seed: seed());
    List<Recipe>? mondayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.monday), seed: seed());
    List<Recipe>? mondayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.monday), seed: seed());

    List<Recipe>? tuesdayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.tuesday), seed: seed());
    List<Recipe>? tuesdayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.tuesday), seed: seed());
    List<Recipe>? tuesdayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.tuesday), seed: seed());

    List<Recipe>? wednesdayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.wednesday), seed: seed());
    List<Recipe>? wednesdayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.wednesday), seed: seed());
    List<Recipe>? wednesdayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.wednesday), seed: seed());

    List<Recipe>? thursdayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.thursday), seed: seed());
    List<Recipe>? thursdayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.thursday), seed: seed());
    List<Recipe>? thursdayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.thursday), seed: seed());

    List<Recipe>? fridayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.friday), seed: seed());
    List<Recipe>? fridayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.friday), seed: seed());
    List<Recipe>? fridayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.friday), seed: seed());

    // *** POPULATE MENU *** //

    List<Recipe> recipesToCook = [
      ...saturdayBreakfast ?? [],
      ...saturdayLunch ?? [],
      ...saturdayDinner ?? [],
      ...sundayBreakfast ?? [],
      ...sundayLunch ?? [],
      ...sundayDinner ?? [],
      ...mondayBreakfast ?? [],
      ...mondayLunch ?? [],
      ...mondayDinner ?? [],
      ...tuesdayBreakfast ?? [],
      ...tuesdayLunch ?? [],
      ...tuesdayDinner ?? [],
      ...wednesdayBreakfast ?? [],
      ...wednesdayLunch ?? [],
      ...wednesdayDinner ?? [],
      ...thursdayBreakfast ?? [],
      ...thursdayLunch ?? [],
      ...thursdayDinner ?? [],
      ...fridayBreakfast ?? [],
      ...fridayLunch ?? [],
      ...fridayDinner ?? []
    ];

    List<Cooking> saturdayBreakfastCook = saturdayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => saturdayBreakfastCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> saturdayLunchCook = saturdayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => saturdayLunchCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> saturdayDinnerCook = saturdayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => saturdayDinnerCook.any((element) => element.recipe.id == toCook.id));

    List<Cooking> sundayBreakfastCook = sundayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => sundayBreakfastCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> sundayLunchCook = sundayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => sundayLunchCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> sundayDinnerCook = sundayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => sundayDinnerCook.any((element) => element.recipe.id == toCook.id));

    List<Cooking> mondayBreakfastCook = mondayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => mondayBreakfastCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> mondayLunchCook = mondayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => mondayLunchCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> mondayDinnerCook = mondayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => mondayDinnerCook.any((element) => element.recipe.id == toCook.id));

    List<Cooking> tuesdayBreakfastCook = tuesdayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => tuesdayBreakfastCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> tuesdayLunchCook = tuesdayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => tuesdayLunchCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> tuesdayDinnerCook = tuesdayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => tuesdayDinnerCook.any((element) => element.recipe.id == toCook.id));

    List<Cooking> wednesdayBreakfastCook = wednesdayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => wednesdayBreakfastCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> wednesdayLunchCook = wednesdayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => wednesdayLunchCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> wednesdayDinnerCook = wednesdayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => wednesdayDinnerCook.any((element) => element.recipe.id == toCook.id));

    List<Cooking> thursdayBreakfastCook = thursdayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => thursdayBreakfastCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> thursdayLunchCook = thursdayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => thursdayLunchCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> thursdayDinnerCook = thursdayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => thursdayDinnerCook.any((element) => element.recipe.id == toCook.id));

    List<Cooking> fridayBreakfastCook = fridayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => fridayBreakfastCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> fridayLunchCook = fridayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => fridayLunchCook.any((element) => element.recipe.id == toCook.id));
    List<Cooking> fridayDinnerCook = fridayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: recipesToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id ? 1 : 0)))).toList() ?? [];
    recipesToCook.removeWhere((toCook) => fridayDinnerCook.any((element) => element.recipe.id == toCook.id));

    if (recipesToCook.isNotEmpty) {
      Debug.logError("Not all recipes have been added to the cooking list");
    }

    Menu menu = Menu(
      meals: [
        if (instance.get(mealType: MealType.breakfast, weekDay: WeekDay.saturday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.saturday, mealType: MealType.breakfast), cookings: saturdayBreakfastCook),
        if (instance.get(mealType: MealType.lunch, weekDay: WeekDay.saturday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.saturday, mealType: MealType.lunch), cookings: saturdayLunchCook),
        if (instance.get(mealType: MealType.dinner, weekDay: WeekDay.saturday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.saturday, mealType: MealType.dinner), cookings: saturdayDinnerCook),
        if (instance.get(mealType: MealType.breakfast, weekDay: WeekDay.sunday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.sunday, mealType: MealType.breakfast), cookings: sundayBreakfastCook),
        if (instance.get(mealType: MealType.lunch, weekDay: WeekDay.sunday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.sunday, mealType: MealType.lunch), cookings: sundayLunchCook),
        if (instance.get(mealType: MealType.dinner, weekDay: WeekDay.sunday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.sunday, mealType: MealType.dinner), cookings: sundayDinnerCook),
        if (instance.get(mealType: MealType.breakfast, weekDay: WeekDay.monday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.breakfast), cookings: mondayBreakfastCook),
        if (instance.get(mealType: MealType.lunch, weekDay: WeekDay.monday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.lunch), cookings: mondayLunchCook),
        if (instance.get(mealType: MealType.dinner, weekDay: WeekDay.monday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.monday, mealType: MealType.dinner), cookings: mondayDinnerCook),
        if (instance.get(mealType: MealType.breakfast, weekDay: WeekDay.tuesday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.tuesday, mealType: MealType.breakfast), cookings: tuesdayBreakfastCook),
        if (instance.get(mealType: MealType.lunch, weekDay: WeekDay.tuesday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.tuesday, mealType: MealType.lunch), cookings: tuesdayLunchCook),
        if (instance.get(mealType: MealType.dinner, weekDay: WeekDay.tuesday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.tuesday, mealType: MealType.dinner), cookings: tuesdayDinnerCook),
        if (instance.get(mealType: MealType.breakfast, weekDay: WeekDay.wednesday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.wednesday, mealType: MealType.breakfast), cookings: wednesdayBreakfastCook),
        if (instance.get(mealType: MealType.lunch, weekDay: WeekDay.wednesday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.wednesday, mealType: MealType.lunch), cookings: wednesdayLunchCook),
        if (instance.get(mealType: MealType.dinner, weekDay: WeekDay.wednesday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.wednesday, mealType: MealType.dinner), cookings: wednesdayDinnerCook),
        if (instance.get(mealType: MealType.breakfast, weekDay: WeekDay.thursday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.thursday, mealType: MealType.breakfast), cookings: thursdayBreakfastCook),
        if (instance.get(mealType: MealType.lunch, weekDay: WeekDay.thursday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.thursday, mealType: MealType.lunch), cookings: thursdayLunchCook),
        if (instance.get(mealType: MealType.dinner, weekDay: WeekDay.thursday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.thursday, mealType: MealType.dinner), cookings: thursdayDinnerCook),
        if (instance.get(mealType: MealType.breakfast, weekDay: WeekDay.friday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.friday, mealType: MealType.breakfast), cookings: fridayBreakfastCook),
        if (instance.get(mealType: MealType.lunch, weekDay: WeekDay.friday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.friday, mealType: MealType.lunch), cookings: fridayLunchCook),
        if (instance.get(mealType: MealType.dinner, weekDay: WeekDay.friday).requiresMeal) Meal(mealTime: const MealTime(weekDay: WeekDay.friday, mealType: MealType.dinner), cookings: fridayDinnerCook),
      ],
    );

    Debug.logDev("Generated menu: ${menu.toJson()}");

    return menu;
  }
}
