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
  MenuProvider._privateConstructor() {
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
    List<Recipe> carbsMeal = RecipesProvider().getOfType(type: RecipeType.meal, carbs: true);
    Debug.logWarning(carbsMeal.isEmpty, "No carbsMeal found");
    List<Recipe> proteinMeal = RecipesProvider().getOfType(type: RecipeType.meal, proteins: true);
    Debug.logWarning(proteinMeal.isEmpty, "No proteinMeal found");
    List<Recipe> veggieMeal = RecipesProvider().getOfType(type: RecipeType.meal, vegetables: true);
    Debug.logWarning(veggieMeal.isEmpty, "No veggieMeal found");

    // TODO: Decide when to use "snacks" saturdays? // Delete category? Or simply don't use it?, just to store recipes
    // List<Recipe> snacks = RecipesProvider().getOfType(type: RecipeType.snack);

    // TODO: Decide when to use "not vegetable desserts"
    // List<Recipe> notVegetableDesserts = RecipesProvider().getOfType(type: RecipeType.dessert, vegetables: false);

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
    // Lunch
    Recipe? lastCarbLunch;
    Recipe? lastVeggieLunch;
    Recipe? lastProteinLunch;
    // Dinner
    Recipe? lastProteinDinner1;
    Recipe? lastVeggieDinner1;
    Recipe? lastCarbsDinner1;
    Recipe? lastProteinDinner2;
    Recipe? lastVeggieDinner2;
    Recipe? lastCarbsDinner2;

    int lastBreakfast = -1; // 1, 2 or 3, 3 total variants of breakfasts
    int lastLunch = -1; // 1, 2 or 3, 3 total variants of lunch meals
    int lastDinner = -1; // 1, 2, 3, 4, 5 or 6, 6 total variants of dinner meals

    Recipe? getRecipeSuggestion({required List<Recipe> candidates, required MenuConfiguration configuration, List<Recipe> otherRecipesOfTheSameMeal = const [], bool? prioritizeLunch, bool? prioritizeDinner}) {
      if (!configuration.requiresMeal) {
        Debug.logError("Configuration does not require a meal, this should never becalled happen");
        return null;
      }

      Debug.log("Getting recipe suggestion for ${configuration.mealTime.weekDay} ${configuration.mealTime.mealType}", signature: "🫕 ");

      List<Recipe> randomizedCandidates = [...candidates];
      int s = seed();
      randomizedCandidates.shuffle(Random(s));
      Debug.log("Seed: $s\nCandidates:\n\t${randomizedCandidates.map((e) => e.name).toList().join("\n\t")}", signature: "\t");

      int cookingTimeAlreadyUsed = otherRecipesOfTheSameMeal.fold(0, (previousValue, element) => previousValue + element.cookingTimeMinutes);

      prioritizeLunch ??= false;
      prioritizeDinner ??= false;
      assert(!(prioritizeLunch && prioritizeDinner), "Cannot prioritize both lunch and dinner");
      bool? lookingForPriority = prioritizeLunch != prioritizeDinner ? true : null;
      for (int i = 0; i < randomizedCandidates.length; i++) {
        Recipe recipe = randomizedCandidates[i];
        if (recipe.cookingTimeMinutes <= configuration.availableCookingTimeMinutes - cookingTimeAlreadyUsed) {
          if (lookingForPriority != null && lookingForPriority == true) {
            if (!recipe.lunch && prioritizeLunch) {
              continue;
            } else if (!recipe.dinner && prioritizeDinner) {
              continue;
            }
          } else if (lookingForPriority != null && lookingForPriority == false) {
            if (recipe.lunch && prioritizeLunch) {
              continue;
            } else if (recipe.dinner && prioritizeDinner) {
              continue;
            }
          }
          Debug.log("Found recipe ${recipe.name}", signature: "\t🍲 ");
          return recipe;
        }
        if (i == randomizedCandidates.length - 1) {
          if (lookingForPriority != null && lookingForPriority == true) {
            lookingForPriority = false;
            i = -1;
          } else {
            // If lookingForPriority is null or false, exit the loop
            // This should never be reached, but just in case
            Debug.logWarning(true, "Reached an unexpected state in getRecipeSuggestion loop. This should never happen.\ncandidatesLength-1: ${randomizedCandidates.length-1} \ni: $i\nlookingForPriority: $lookingForPriority\nprioritizeLunch: $prioritizeLunch\nprioritizeDinner: $prioritizeDinner");
            break;
          }
        }
      }

      return null;
    }

    // Prefer heavy meals for lunch
    // Prefer light meals for dinner, unless some of the heavy meals have not been selected
    List<Recipe>? getMealFor({required MenuConfiguration configuration, required int seed}) {
      Debug.log("Getting meal for ${configuration.mealTime.weekDay} ${configuration.mealTime.mealType}. Requires meal: ${configuration.requiresMeal}", signature: "🗒️ ", messageColor: ColorsConsole.green);
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
          int selectedLunch = -1;
          if (lastCarbLunch == null) {
            selectedLunch = 1;
          } else if (lastVeggieLunch == null) {
            selectedLunch = 2;
          } else if (lastProteinLunch == null) {
            selectedLunch = 3;
          } else {
            if (lastLunch == 1) {
              selectedLunch = 2;
            } else if (lastLunch == 2) {
              selectedLunch = 3;
            } else if (lastLunch == 3) {
              selectedLunch = 1;
            }
          }
          // Pick a recipe
          if (selectedLunch == 1) {
            if (lastCarbLunch != null && lastCarbLunch!.canBeStored) {
              recipes = [lastCarbLunch!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: carbsMeal, prioritizeLunch: true, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastCarbLunch = recipe;
              lastLunch = 1;
              recipes = [lastCarbLunch!];
            }
          } else if (selectedLunch == 2) {
            if (lastVeggieLunch != null && lastVeggieLunch!.canBeStored) {
              recipes = [lastVeggieLunch!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: veggieMeal, prioritizeLunch: true, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastVeggieLunch = recipe;
              lastLunch = 2;
              recipes = [lastVeggieLunch!];
            }
          } else if (selectedLunch == 3) {
            if (lastProteinLunch != null && lastProteinLunch!.canBeStored) {
              recipes = [lastProteinLunch!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: proteinMeal, prioritizeLunch: true, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastProteinLunch = recipe;
              lastLunch = 3;
              recipes = [lastProteinLunch!];
            }
          }

        case MealType.dinner:

          // Before any dinner meal, first ensure all lunch meals have been selected
          if (lastCarbLunch == null || lastProteinLunch == null || lastVeggieLunch == null) {
            Debug.logDev("Not all lunch meals have been selected, cannot select dinner meal for ${configuration.mealTime.weekDay} ${configuration.mealTime.mealType}. Selecting a lunch meal instead.");
            List<Recipe>? r = getMealFor(configuration: configuration.copyWith(mealTime: configuration.mealTime.copyWith(mealType: MealType.lunch)), seed: seed);
            if (r != null) {
              return r;
            }
          }

          // Pick a light meal number
          int selectedDinner = -1;
          if (lastProteinDinner1 == null) {
            selectedDinner = 1;
          } else if (lastVeggieDinner1 == null) {
            selectedDinner = 2;
          } else if (lastCarbsDinner1 == null) {
            selectedDinner = 3;
          } else if (lastProteinDinner2 == null) {
            selectedDinner = 4;
          } else if (lastVeggieDinner2 == null) {
            selectedDinner = 5;
          } else if (lastCarbsDinner2 == null) {
            selectedDinner = 6;
          } else {
            if (lastDinner == 1) {
              selectedDinner = 2;
            } else if (lastDinner == 2) {
              selectedDinner = 3;
            } else if (lastDinner == 3) {
              selectedDinner = 4;
            } else if (lastDinner == 4) {
              selectedDinner = 5;
            } else if (lastDinner == 5) {
              selectedDinner = 6;
            } else if (lastDinner == 6) {
              selectedDinner = 1;
            }
          }

          // Pick a recipe
          if (selectedDinner == 1) {
            if (lastProteinDinner1 != null && lastProteinDinner1!.canBeStored) {
              recipes = [lastProteinDinner1!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: proteinMeal, prioritizeDinner: true, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastProteinDinner1 = recipe;
              lastDinner = 1;
              recipes = [lastProteinDinner1!];
            }
          } else if (selectedDinner == 2) {
            if (lastVeggieDinner1 != null && lastVeggieDinner1!.canBeStored) {
              recipes = [lastVeggieDinner1!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: veggieMeal, prioritizeDinner: true, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastVeggieDinner1 = recipe;
              lastDinner = 2;
              recipes = [lastVeggieDinner1!];
            }
          } else if (selectedDinner == 3) {
            if (lastCarbsDinner1 != null && lastCarbsDinner1!.canBeStored) {
              recipes = [lastCarbsDinner1!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: carbsMeal, prioritizeDinner: true, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastCarbsDinner1 = recipe;
              lastDinner = 3;
              recipes = [lastCarbsDinner1!];
            }
          } else if (selectedDinner == 4) {
            if (lastProteinDinner2 != null && lastProteinDinner2!.canBeStored) {
              recipes = [lastProteinDinner2!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: proteinMeal, prioritizeDinner: true, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastProteinDinner2 = recipe;
              lastDinner = 4;
              recipes = [lastProteinDinner2!];
            }
          } else if (selectedDinner == 5) {
            if (lastVeggieDinner2 != null && lastVeggieDinner2!.canBeStored) {
              recipes = [lastVeggieDinner2!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: veggieMeal, prioritizeDinner: true, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastVeggieDinner2 = recipe;
              lastDinner = 5;
              recipes = [lastVeggieDinner2!];
            }
          } else if (selectedDinner == 6) {
            if (lastCarbsDinner2 != null && lastCarbsDinner2!.canBeStored) {
              recipes = [lastCarbsDinner2!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: carbsMeal, prioritizeDinner: true, configuration: configuration);
              if (recipe == null) {
                return null;
              }
              lastCarbsDinner2 = recipe;
              lastDinner = 6;
              recipes = [lastCarbsDinner2!];
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

    // Debug.logDev("Generated menu: ${menu.toJson()}");

    return menu;
  }
}
