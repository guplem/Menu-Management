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
    List<Recipe> carbsMeals = RecipesProvider().getOfType(type: RecipeType.meal, carbs: true);
    Debug.logWarning(carbsMeals.isEmpty, "No carbsMeals found");
    List<Recipe> proteinMeals = RecipesProvider().getOfType(type: RecipeType.meal, proteins: true);
    Debug.logWarning(proteinMeals.isEmpty, "No proteinMeals found");
    List<Recipe> veggieMeals = RecipesProvider().getOfType(type: RecipeType.meal, vegetables: true);
    Debug.logWarning(veggieMeals.isEmpty, "No veggieMeals found");

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

    Set<Recipe> uniqueSelectedRecipes = {};

    Recipe? getRecipeSuggestion({
      required List<Recipe> candidates,
      required MenuConfiguration configuration,
      List<Recipe> otherRecipesOfTheSameMeal = const [],
      bool? prioritizeLunch,
      bool? prioritizeDinner,
      bool onlyUseRecipesThatCanBeStored = false,
      bool removeAlreadySelectedRecipesFromCandidates = true,
    }) {
      if (!configuration.requiresMeal) {
        Debug.logError("Configuration does not require a meal, this should never happen");
        return null;
      }

      Debug.log("Getting recipe suggestion for configuration with available time of ${configuration.availableCookingTimeMinutes}", signature: "🫕 ", maxStackTraceRows: 2);

      List<Recipe> cleanCandidates = [...candidates];
      if (onlyUseRecipesThatCanBeStored) {
        cleanCandidates.removeWhere((element) => !element.canBeStored);
      }
      if (removeAlreadySelectedRecipesFromCandidates) {
        cleanCandidates.removeWhere((element) => uniqueSelectedRecipes.any((selectedRecipe) => selectedRecipe.id == element.id));
      }
      cleanCandidates.shuffle(Random(seed()));
      Debug.log("Candidates:\n\t${cleanCandidates.map((e) => e.name).toList().join("\n\t")}", signature: "\t");

      int cookingTimeAlreadyUsed = otherRecipesOfTheSameMeal.fold(0, (previousValue, element) => previousValue + element.cookingTimeMinutes);

      prioritizeLunch ??= false;
      prioritizeDinner ??= false;
      assert(!(prioritizeLunch && prioritizeDinner), "Cannot prioritize both lunch and dinner");
      bool? lookingForPriority = prioritizeLunch != prioritizeDinner ? true : null;
      for (int i = 0; i < cleanCandidates.length; i++) {
        Recipe recipe = cleanCandidates[i];
        if (recipe.cookingTimeMinutes <= configuration.availableCookingTimeMinutes - cookingTimeAlreadyUsed) {
          if (lookingForPriority != null && lookingForPriority == true) {
            // If lookingForPriority is true, return the first recipe that fits the priority settings
            if ((recipe.lunch && prioritizeLunch) || (recipe.dinner && prioritizeDinner)) {
              return recipe;
            }
          } else if (lookingForPriority != null && lookingForPriority == false) {
            // If lookingForPriority is false (aka looking for a non-priority meal), return the first recipe that is not within the priority settings
            if ((!recipe.lunch && prioritizeLunch) || (!recipe.dinner && prioritizeDinner)) {
              return recipe;
            }
          } else {
            // If lookingForPriority is null (aka not looking for anything in particular), return the first recipe that fits
            return recipe;
          }
        }
        if (i == cleanCandidates.length - 1) {
          if (lookingForPriority != null && lookingForPriority == true) {
            // Debug.logDev("Exhausted options while looking for the priority meal, looking for the non-prioritized meals");
            lookingForPriority = false;
            i = -1;
          } else {
            // If lookingForPriority is null or false, exit the loop
            // This should never be reached, but just in case
            Debug.logWarning(true, "Reached an unexpected state in getRecipeSuggestion loop. This should never happen.\ncandidatesLength-1: ${cleanCandidates.length - 1} \ni: $i\nlookingForPriority: $lookingForPriority\nprioritizeLunch: $prioritizeLunch\nprioritizeDinner: $prioritizeDinner");
            break;
          }
        }
      }

      Debug.log(
          "No recipe found for ${configuration.mealTime.weekDay} ${configuration.mealTime.mealType}.\nAvailable time: ${configuration.availableCookingTimeMinutes - cookingTimeAlreadyUsed}.\nCandidates: ${cleanCandidates.map((e) => e.name).toList().join(", ")}.\nOther recipes of the same meal: ${otherRecipesOfTheSameMeal.map((e) => e.name).toList().join(", ")}",
          signature: "❌ ",
          messageColor: ColorsConsole.red);
      return null;
    }

    // Prefer heavy meals for lunch
    // Prefer light meals for dinner, unless some of the heavy meals have not been selected
    List<Recipe>? getMealFor({required MenuConfiguration configuration, required int seed}) {
      Debug.log("Getting meal for ${configuration.mealTime.weekDay} ${configuration.mealTime.mealType}. Requires meal: ${configuration.requiresMeal}", signature: "🗒️ ", messageColor: ColorsConsole.green, maxStackTraceRows: 2);
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
              Recipe? recipe = getRecipeSuggestion(candidates: breakfasts, configuration: configuration, removeAlreadySelectedRecipesFromCandidates: false);
              if (recipe == null) {
                // TODO: Show error dialog with proper information
                Debug.logError("Recipe not found among breakfasts (${breakfasts.length})");
                return null;
              }
              lastBreakfast1 = recipe;
              recipes = [lastBreakfast1!];
            }
            lastBreakfast = 1;
          } else if (selectedBreakfast == 2) {
            if (lastBreakfast2 != null && lastBreakfast2!.canBeStored) {
              recipes = [lastBreakfast2!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: breakfasts, configuration: configuration, removeAlreadySelectedRecipesFromCandidates: false);
              if (recipe == null) {
                // TODO: Show error dialog with proper information
                Debug.logError("Recipe not found among breakfasts (${breakfasts.length})");
                return null;
              }
              lastBreakfast2 = recipe;
              recipes = [lastBreakfast2!];
            }
            lastBreakfast = 2;
          } else if (selectedBreakfast == 3) {
            if (lastBreakfast3 != null && lastBreakfast3!.canBeStored) {
              recipes = [lastBreakfast3!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: breakfasts, configuration: configuration, removeAlreadySelectedRecipesFromCandidates: false);
              if (recipe == null) {
                // TODO: Show error dialog with proper information
                Debug.logError("Recipe not found among breakfasts (${breakfasts.length})");
                return null;
              }
              lastBreakfast3 = recipe;
              recipes = [lastBreakfast3!];
            }
            lastBreakfast = 3;
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
          Debug.logDev("Selected lunch: $selectedLunch");
          // Pick a recipe
          if (selectedLunch == 1) {
            // Carbs
            if (lastCarbLunch != null && lastCarbLunch!.canBeStored) {
              recipes = [lastCarbLunch!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: carbsMeals, prioritizeLunch: true, configuration: configuration, onlyUseRecipesThatCanBeStored: true);
              if (recipe == null) {
                // TODO: Show error dialog with proper information
                Debug.logError("Recipe not found among carbsMeals (${carbsMeals.length})");
                return null;
              }
              lastCarbLunch = recipe;
              recipes = [lastCarbLunch!];
            }
            lastLunch = 1;
          } else if (selectedLunch == 2) {
            // Vegetables
            if (lastVeggieLunch != null && lastVeggieLunch!.canBeStored) {
              recipes = [lastVeggieLunch!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: veggieMeals, prioritizeLunch: true, configuration: configuration, onlyUseRecipesThatCanBeStored: true);
              if (recipe == null) {
                // TODO: Show error dialog with proper information
                Debug.logError("Recipe not found among veggieMeals (${veggieMeals.length})");
                return null;
              }
              lastVeggieLunch = recipe;
              recipes = [lastVeggieLunch!];
            }
            lastLunch = 2;
          } else if (selectedLunch == 3) {
            // Proteins
            if (lastProteinLunch != null && lastProteinLunch!.canBeStored) {
              recipes = [lastProteinLunch!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: proteinMeals, prioritizeLunch: true, configuration: configuration, onlyUseRecipesThatCanBeStored: true);
              if (recipe == null) {
                // TODO: Show error dialog with proper information
                Debug.logError("Recipe not found among proteinMeals (${proteinMeals.length})");
                return null;
              }
              lastProteinLunch = recipe;
              recipes = [lastProteinLunch!];
            }
            lastLunch = 3;
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
            // Proteins 1
            if (lastProteinDinner1 != null && lastProteinDinner1!.canBeStored) {
              recipes = [lastProteinDinner1!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: proteinMeals, prioritizeDinner: true, configuration: configuration);
              if (recipe == null) {
                // TODO: Show error dialog with proper information
                Debug.logError("Recipe not found among proteinMeals (${proteinMeals.length})");
                return null;
              }
              lastProteinDinner1 = recipe;
              recipes = [lastProteinDinner1!];
            }
            lastDinner = 1;
          } else if (selectedDinner == 2) {
            // Vegetables 1
            if (lastVeggieDinner1 != null && lastVeggieDinner1!.canBeStored) {
              recipes = [lastVeggieDinner1!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: veggieMeals, prioritizeDinner: true, configuration: configuration);
              if (recipe == null) {
                // TODO: Show error dialog with proper information
                Debug.logError("Recipe not found among veggieMeals (${veggieMeals.length})");
                return null;
              }
              lastVeggieDinner1 = recipe;
              recipes = [lastVeggieDinner1!];
            }
            lastDinner = 2;
          } else if (selectedDinner == 3) {
            // Carbs 1
            if (lastCarbsDinner1 != null && lastCarbsDinner1!.canBeStored) {
              recipes = [lastCarbsDinner1!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: carbsMeals, prioritizeDinner: true, configuration: configuration);
              if (recipe == null) {
                // TODO: Show error dialog with proper information
                Debug.logError("Recipe not found among carbsMeals (${carbsMeals.length})");
                return null;
              }
              lastCarbsDinner1 = recipe;
              recipes = [lastCarbsDinner1!];
            }
            lastDinner = 3;
          } else if (selectedDinner == 4) {
            // Proteins 2
            if (lastProteinDinner2 != null && lastProteinDinner2!.canBeStored) {
              recipes = [lastProteinDinner2!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: proteinMeals, prioritizeDinner: true, configuration: configuration);
              if (recipe == null) {
                // TODO: Show error dialog with proper information
                Debug.logError("Recipe not found among proteinMeals (${proteinMeals.length})");
                return null;
              }
              lastProteinDinner2 = recipe;
              recipes = [lastProteinDinner2!];
            }
            lastDinner = 4;
          } else if (selectedDinner == 5) {
            // Vegetables 2
            if (lastVeggieDinner2 != null && lastVeggieDinner2!.canBeStored) {
              recipes = [lastVeggieDinner2!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: veggieMeals, prioritizeDinner: true, configuration: configuration);
              if (recipe == null) {
                // TODO: Show error dialog with proper information
                Debug.logError("Recipe not found among veggieMeals (${veggieMeals.length})");
                return null;
              }
              lastVeggieDinner2 = recipe;
              recipes = [lastVeggieDinner2!];
            }
            lastDinner = 5;
          } else if (selectedDinner == 6) {
            // Carbs 2
            if (lastCarbsDinner2 != null && lastCarbsDinner2!.canBeStored) {
              recipes = [lastCarbsDinner2!];
            } else {
              Recipe? recipe = getRecipeSuggestion(candidates: carbsMeals, prioritizeDinner: true, configuration: configuration);
              if (recipe == null) {
                // TODO: Show error dialog with proper information
                Debug.logError("Recipe not found among carbsMeals (${carbsMeals.length})");
                return null;
              }
              lastCarbsDinner2 = recipe;
              recipes = [lastCarbsDinner2!];
            }
            lastDinner = 6;
          }
      }

      if (recipes == null) {
        Debug.logError("No recipe found for ${configuration.mealTime.weekDay} ${configuration.mealTime.mealType}");
      }

      // TODO: Populate snacks and desserts, take into account the available cooking time by using the parameter otherRecipesOfTheSameMeal of the method getRecipeSuggestion

      return recipes;
    }

    List<Recipe>? saturdayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.saturday), seed: seed());
    uniqueSelectedRecipes.addAll(saturdayBreakfast ?? []);
    List<Recipe>? saturdayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.saturday), seed: seed());
    uniqueSelectedRecipes.addAll(saturdayLunch ?? []);
    List<Recipe>? saturdayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.saturday), seed: seed());
    uniqueSelectedRecipes.addAll(saturdayDinner ?? []);

    List<Recipe>? sundayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.sunday), seed: seed());
    uniqueSelectedRecipes.addAll(sundayBreakfast ?? []);
    List<Recipe>? sundayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.sunday), seed: seed());
    uniqueSelectedRecipes.addAll(sundayLunch ?? []);
    List<Recipe>? sundayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.sunday), seed: seed());
    uniqueSelectedRecipes.addAll(sundayDinner ?? []);

    List<Recipe>? mondayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.monday), seed: seed());
    uniqueSelectedRecipes.addAll(mondayBreakfast ?? []);
    List<Recipe>? mondayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.monday), seed: seed());
    uniqueSelectedRecipes.addAll(mondayLunch ?? []);
    List<Recipe>? mondayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.monday), seed: seed());
    uniqueSelectedRecipes.addAll(mondayDinner ?? []);

    List<Recipe>? tuesdayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.tuesday), seed: seed());
    uniqueSelectedRecipes.addAll(tuesdayBreakfast ?? []);
    List<Recipe>? tuesdayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.tuesday), seed: seed());
    uniqueSelectedRecipes.addAll(tuesdayLunch ?? []);
    List<Recipe>? tuesdayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.tuesday), seed: seed());
    uniqueSelectedRecipes.addAll(tuesdayDinner ?? []);

    List<Recipe>? wednesdayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.wednesday), seed: seed());
    uniqueSelectedRecipes.addAll(wednesdayBreakfast ?? []);
    List<Recipe>? wednesdayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.wednesday), seed: seed());
    uniqueSelectedRecipes.addAll(wednesdayLunch ?? []);
    List<Recipe>? wednesdayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.wednesday), seed: seed());
    uniqueSelectedRecipes.addAll(wednesdayDinner ?? []);

    List<Recipe>? thursdayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.thursday), seed: seed());
    uniqueSelectedRecipes.addAll(thursdayBreakfast ?? []);
    List<Recipe>? thursdayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.thursday), seed: seed());
    uniqueSelectedRecipes.addAll(thursdayLunch ?? []);
    List<Recipe>? thursdayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.thursday), seed: seed());
    uniqueSelectedRecipes.addAll(thursdayDinner ?? []);

    List<Recipe>? fridayBreakfast = getMealFor(configuration: instance.get(mealType: MealType.breakfast, weekDay: WeekDay.friday), seed: seed());
    uniqueSelectedRecipes.addAll(fridayBreakfast ?? []);
    List<Recipe>? fridayLunch = getMealFor(configuration: instance.get(mealType: MealType.lunch, weekDay: WeekDay.friday), seed: seed());
    uniqueSelectedRecipes.addAll(fridayLunch ?? []);
    List<Recipe>? fridayDinner = getMealFor(configuration: instance.get(mealType: MealType.dinner, weekDay: WeekDay.friday), seed: seed());
    uniqueSelectedRecipes.addAll(fridayDinner ?? []);

    // *** POPULATE MENU *** //

    List<Recipe> mealsToCook = [
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

    getYieldsMorMealsToCook(Recipe mealRecipe) {
      int calculated = mealsToCook.fold(0, (previousValue, toCook) => previousValue + (toCook.id == mealRecipe.id && mealRecipe.canBeStored ? 1 : 0));
      calculated = calculated == 0 ? 1 : calculated;
      int mealsToCookCount = mealsToCook.where((toCook) => toCook.id == mealRecipe.id).length;
      return min(calculated, mealsToCookCount);
    }

    removeCookedMealsFrom(List<Cooking> cookingList) {
      List<Recipe> toRemove = [];
      for (Cooking cookingPlan in cookingList) {
        int quantityToRemove = cookingPlan.yield;
        if (quantityToRemove <= 0) {
          continue;
        }
        for (Recipe toCook in mealsToCook) {
          if (toCook.id == cookingPlan.recipe.id) {
            quantityToRemove--;
            toRemove.add(toCook);
            if (quantityToRemove <= 0) {
              break;
            }
          }
        }
      }
      for (Recipe toRemoveRecipe in toRemove) {
        mealsToCook.remove(toRemoveRecipe);
      }
    }

    List<Cooking> saturdayBreakfastCook = saturdayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(saturdayBreakfastCook);
    List<Cooking> saturdayLunchCook = saturdayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(saturdayLunchCook);
    List<Cooking> saturdayDinnerCook = saturdayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(saturdayDinnerCook);

    List<Cooking> sundayBreakfastCook = sundayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(sundayBreakfastCook);
    List<Cooking> sundayLunchCook = sundayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(sundayLunchCook);
    List<Cooking> sundayDinnerCook = sundayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(sundayDinnerCook);

    List<Cooking> mondayBreakfastCook = mondayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(mondayBreakfastCook);
    List<Cooking> mondayLunchCook = mondayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(mondayLunchCook);
    List<Cooking> mondayDinnerCook = mondayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(mondayDinnerCook);

    List<Cooking> tuesdayBreakfastCook = tuesdayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(tuesdayBreakfastCook);
    List<Cooking> tuesdayLunchCook = tuesdayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(tuesdayLunchCook);
    List<Cooking> tuesdayDinnerCook = tuesdayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(tuesdayDinnerCook);

    List<Cooking> wednesdayBreakfastCook = wednesdayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(wednesdayBreakfastCook);
    List<Cooking> wednesdayLunchCook = wednesdayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(wednesdayLunchCook);
    List<Cooking> wednesdayDinnerCook = wednesdayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(wednesdayDinnerCook);

    List<Cooking> thursdayBreakfastCook = thursdayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(thursdayBreakfastCook);
    List<Cooking> thursdayLunchCook = thursdayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(thursdayLunchCook);
    List<Cooking> thursdayDinnerCook = thursdayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(thursdayDinnerCook);

    List<Cooking> fridayBreakfastCook = fridayBreakfast?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(fridayBreakfastCook);
    List<Cooking> fridayLunchCook = fridayLunch?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(fridayLunchCook);
    List<Cooking> fridayDinnerCook = fridayDinner?.map((Recipe mealRecipe) => Cooking(recipe: mealRecipe, yield: getYieldsMorMealsToCook(mealRecipe))).toList() ?? [];
    removeCookedMealsFrom(fridayDinnerCook);

    if (mealsToCook.isNotEmpty) {
      Debug.logError("Not all recipes have been added to the cooking list. This should never happen.\nRecipes not (cooked) added (${mealsToCook.length}): ${mealsToCook.map((e) => e.name).toList().join(", ")}");
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
