import 'dart:math';

import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/menu/enums/meal_type.dart';
import 'package:menu_management/menu/models/cooking.dart';
import 'package:menu_management/menu/models/meal.dart';
import 'package:menu_management/menu/models/meal_time.dart';
import 'package:menu_management/menu/models/menu_configuration.dart';
import 'package:menu_management/recipes/enums/recipe_type.dart';
import 'package:menu_management/recipes/models/recipe.dart';
import 'package:menu_management/recipes/recipes_provider.dart';

import 'models/menu.dart';

class MenuGenerator {
  MenuGenerator({required this.baseSeed});

  late final int baseSeed;
  int seedIncrementTimes = 0;

  int get seed {
    seedIncrementTimes++;
    return baseSeed + seedIncrementTimes;
  }

  Menu? menu;

  void generate({required List<MenuConfiguration> configurations}) {

    Debug.log("Generating menu...");

    menu = null;

    List<MenuConfiguration> breakfastConfigurations = configurations.where((element) => element.requiresMeal && element.mealTime.mealType == MealType.breakfast).toList();
    List<Recipe> breakfastsRecipes = RecipesProvider().getOfType(type: RecipeType.breakfast).shuffled(Random(seed)).toList();
    Debug.logWarning(breakfastsRecipes.isEmpty, "No breakfasts found");
    Map<MealTime, Recipe?> breakfastRecipes = getRecipesFor(recipesToConsider: breakfastsRecipes, configurationsToFindRecipesFor: breakfastConfigurations);

    List<MenuConfiguration> mealsConfigurations = configurations.where((element) => element.requiresMeal && (element.mealTime.mealType == MealType.lunch || element.mealTime.mealType == MealType.dinner)).toList();
    List<Recipe> mealsRecipes = RecipesProvider().getOfType(type: RecipeType.meal).shuffled(Random(seed)).toList();
    Debug.logWarning(mealsRecipes.isEmpty, "No meals found");
    Map<MealTime, Recipe?> mealsRecipesMap = getRecipesFor(recipesToConsider: mealsRecipes, configurationsToFindRecipesFor: mealsConfigurations);

    Map<MealTime, Recipe?> allSelected = {...breakfastRecipes, ...mealsRecipesMap};

    bool isFirstTimeOfRecipe(MealTime time, Recipe recipe) {
      List<MealTime> sortedMealTimes = allSelected.keys.sorted((a, b) => a.goesBefore(b) ? -1 : 1).toList();
      for(int i = 0; i < sortedMealTimes.length; i++) {
        MealTime t = sortedMealTimes[i];
        Recipe? r = allSelected[t];
        if (r == recipe && t.goesBefore(time)) {
          return false;
        } else if (r == recipe && (t == time || time.goesBefore(t))) {
          return true;
        }
      }
      Debug.logError("This should not happen");
      return false;
    }

    List<Meal> meals = configurations.map((config) {
      Recipe? recipe = allSelected[config.mealTime];

      int yield = 1;
      if (recipe != null && recipe.canBeStored) {
        if (isFirstTimeOfRecipe(config.mealTime, recipe)) {
          yield = allSelected.values.fold(0, (previousValue, element) => previousValue + (element == recipe ? 1 : 0));
        } else {
          yield = 0;
        }
      }

      return Meal(
        mealTime: config.mealTime,
        cookings: recipe == null
            ? []
            : [
                Cooking(
                  recipe: recipe,
                  yield: yield,
                ),
              ],
      );
    }).toList();

    menu = Menu(meals: meals);
  }

  Recipe? getValidRecipeForConfiguration({required MenuConfiguration configuration, required List<Recipe> candidates, required bool needToBeStored, required List<Recipe> alreadySelected, required bool strictMealTime}) {
    // Count the number of recipes of each type that have already been selected
    int selectedCarbs = 0; // ID: 1
    int selectedProteins = 0; // ID: 2
    int selectedVegetables = 0; // ID: 3
    for (Recipe recipe in alreadySelected) {
      if (recipe.carbs) {
        selectedCarbs++;
      }
      if (recipe.proteins) {
        selectedProteins++;
      }
      if (recipe.vegetables) {
        selectedVegetables++;
      }
    }
    // Helper function to get the number of recipes of each type that have already been selected
    int getSelectedAmountById(int id) {
      switch (id) {
        case 1:
          return selectedCarbs;
        case 2:
          return selectedProteins;
        case 3:
          return selectedVegetables;
        default:
          return 0;
      }
    }

    List<int> fromLeastSelectedToMostSelectedIds = [1, 2, 3].sorted((a, b) {
      return getSelectedAmountById(a).compareTo(getSelectedAmountById(b));
    }).toList();

    // Get the for each type of recipe
    List<Recipe> shuffledCandidates = candidates.shuffled(Random(seed)).toList();
    List<Recipe> carbsCandidates = shuffledCandidates.where((element) => element.carbs).toList();
    List<Recipe> proteinsCandidates = shuffledCandidates.where((element) => element.proteins).toList();
    List<Recipe> vegetablesCandidates = shuffledCandidates.where((element) => element.vegetables).toList();
    List<Recipe> otherCandidates = shuffledCandidates.where((element) => !element.carbs && !element.proteins && !element.vegetables).toList();
    Recipe? carbsRecipe = carbsCandidates.firstWhereOrNull((recipe) => recipe.fitsConfiguration(configuration, needToBeStored: needToBeStored, strictMealTime: strictMealTime));
    Recipe? proteinsRecipe = proteinsCandidates.firstWhereOrNull((recipe) => recipe.fitsConfiguration(configuration, needToBeStored: needToBeStored, strictMealTime: strictMealTime));
    Recipe? vegetablesRecipe = vegetablesCandidates.firstWhereOrNull((recipe) => recipe.fitsConfiguration(configuration, needToBeStored: needToBeStored, strictMealTime: strictMealTime));
    Recipe? otherRecipe = otherCandidates.firstWhereOrNull((recipe) => recipe.fitsConfiguration(configuration, needToBeStored: needToBeStored, strictMealTime: strictMealTime));

    // Get the recipes prioritizing the least selected ones
    List<Recipe?> recipesByLeastSelected = [];
    for (int id in fromLeastSelectedToMostSelectedIds) {
      switch (id) {
        case 1:
          recipesByLeastSelected.add(carbsRecipe);
          break;
        case 2:
          recipesByLeastSelected.add(proteinsRecipe);
          break;
        case 3:
          recipesByLeastSelected.add(vegetablesRecipe);
          break;
      }
    }
    recipesByLeastSelected.add(otherRecipe);

    // Return the first valid recipe
    return recipesByLeastSelected.firstOrNull;
  }

  List<MenuConfiguration> getPreviousMomentConfigurations({required MenuConfiguration previousThan, required List<MenuConfiguration> possibleConfigurations}) {
    List<MenuConfiguration> sortedConfigurations = [previousThan, ...possibleConfigurations].sorted((a, b) => a.goesBefore(b) ? -1 : 1).toList();
    int previousThanIndex = sortedConfigurations.indexOf(previousThan);
    return sortedConfigurations.sublist(0, previousThanIndex);
  }

  Map<MealTime, Recipe?> getRecipesFor({required List<MenuConfiguration> configurationsToFindRecipesFor, required List<Recipe> recipesToConsider}) {
    Map<MealTime, Recipe?> result = {};

    int configurationsThatCanBeCookedAtTheSpot = configurationsToFindRecipesFor.where((element) => element.canBeCookedAtTheSpot).length;
    int configurationsThatCannotBeCookedAtTheSpot = configurationsToFindRecipesFor.where((element) => !element.canBeCookedAtTheSpot).length;
    int maxNumberOfTimesTheSameRecipeCanBeUsed = (configurationsThatCannotBeCookedAtTheSpot / configurationsThatCanBeCookedAtTheSpot).ceil() + 1;
    int numberOfTimesTheRecipeHasBeenUsed(Recipe recipe) => result.values.whereType<Recipe>().where((element) => element == recipe).length;
    Recipe recipeFromTheSelectedOnesThatHasBeenSelectedTheLeast() => result.values.whereType<Recipe>().reduce((value, element) => numberOfTimesTheRecipeHasBeenUsed(value) < numberOfTimesTheRecipeHasBeenUsed(element) ? value : element);

    // Set the list to contain the maximum number recipes of each type
    recipesToConsider = recipesToConsider.expand((recipe) {
      return List.generate(maxNumberOfTimesTheSameRecipeCanBeUsed, (index) => recipe);
    }).toList();

    // Sort by available cooking time
    List<MenuConfiguration> configsByAvailableTime = [...configurationsToFindRecipesFor].sorted((a, b) => a.availableCookingTimeMinutes.compareTo(b.availableCookingTimeMinutes)).toList();
    for (int i = 0; i < configsByAvailableTime.length; i++) {
      MenuConfiguration configWithTheLeastAvailableTime = configsByAvailableTime[i];

      if (result.containsKey(configWithTheLeastAvailableTime.mealTime)) {
        // The configuration has already been set (maybe by a configuration with lower available cooking time)
        continue;
      }

      // Get the recipe for the configuration with the least available cooking time
      Recipe? recipe = getValidRecipeForConfiguration(strictMealTime: true, configuration: configWithTheLeastAvailableTime, candidates: recipesToConsider, needToBeStored: false, alreadySelected: result.values.whereType<Recipe>().toList());
      if (recipe != null) {
        // Valid recipe found. Set it for the configuration
        result[configWithTheLeastAvailableTime.mealTime] = recipe;
        recipesToConsider.remove(recipe);
      } else {
        // Valid recipe not found. Try to get the recipe for the nearest previous moment
        List<MenuConfiguration> possibleMoments = [...configurationsToFindRecipesFor].sublist(i);

        // Remove those that can not cook at the spot
        possibleMoments.removeWhere((element) => !element.canBeCookedAtTheSpot);

        // List all the configuration that are form moments previous than the current one
        List<MenuConfiguration> previousMomentConfigurations = getPreviousMomentConfigurations(previousThan: configWithTheLeastAvailableTime, possibleConfigurations: configurationsToFindRecipesFor);

        // Filter out the configurations that have already been set
        possibleMoments.removeWhere((MenuConfiguration config) => result.containsKey(config.mealTime));

        // Check if all the previous moments have already been set
        List<MenuConfiguration> previousMomentsWithAlreadySelectedMeal = previousMomentConfigurations.where((element) => result.containsKey(element.mealTime)).toList();
        if (previousMomentsWithAlreadySelectedMeal.length >= previousMomentConfigurations.length) {
          // All the previous moments have already been set.
          Recipe recipe = recipeFromTheSelectedOnesThatHasBeenSelectedTheLeast();
          result[configWithTheLeastAvailableTime.mealTime] = recipe;
          recipesToConsider.remove(recipe);
        } else {
          // There are previous moments that have not been set yet.

          // Remove the previous moments that have already been set
          previousMomentConfigurations.removeWhere((MenuConfiguration config) => result.containsKey(config.mealTime));

          while (previousMomentConfigurations.isNotEmpty) {
            // Select the previous moment configuration, being the one that is further away from the current moment (as early as possible)
            MenuConfiguration selectedPreviousMomentConfiguration = previousMomentConfigurations.first;
            // There is a previous moment. Try to get the recipe for it
            recipe = getValidRecipeForConfiguration(strictMealTime: false, configuration: selectedPreviousMomentConfiguration, candidates: recipesToConsider, needToBeStored: true, alreadySelected: result.values.whereType<Recipe>().toList());
            if (recipe == null) {
              // Valid recipe not found for the previous moment. Remove the previous moment from the possible moments
              previousMomentConfigurations.remove(selectedPreviousMomentConfiguration);
            } else {
              // Valid recipe found for the previous moment.
              result[selectedPreviousMomentConfiguration.mealTime] = recipe;
              result[configWithTheLeastAvailableTime.mealTime] = recipe;
              recipesToConsider.remove(recipe);
              break;
            }
          }
        }
      }
    }

    return result;
  }
}
