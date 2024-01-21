import 'dart:math';

import 'package:menu_management/flutter_essentials/library.dart';
import 'package:menu_management/menu/enums/meal_type.dart';
import 'package:menu_management/menu/enums/week_day.dart';
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
    Set<Recipe> breakfastsRecipes = RecipesProvider().getOfType(type: RecipeType.breakfast).shuffled(Random(seed)).toSet();
    Debug.logWarning(breakfastsRecipes.isEmpty, "No breakfasts found");
    Map<MealTime, Recipe?> breakfastRecipes = getRecipesFor(recipesToConsider: breakfastsRecipes, configurationsToFindRecipesFor: breakfastConfigurations);

    List<MenuConfiguration> mealsConfigurations = configurations.where((element) => element.requiresMeal && (element.mealTime.mealType == MealType.lunch || element.mealTime.mealType == MealType.dinner)).toList();
    Set<Recipe> mealsRecipes = RecipesProvider().getOfType(type: RecipeType.meal).shuffled(Random(seed)).toSet();
    Debug.logWarning(mealsRecipes.isEmpty, "No meals found");
    Map<MealTime, Recipe?> mealsRecipesMap = getRecipesFor(recipesToConsider: mealsRecipes, configurationsToFindRecipesFor: mealsConfigurations);

    Map<MealTime, Recipe?> allSelected = {...breakfastRecipes, ...mealsRecipesMap};

    bool isFirstTimeOfRecipe(MealTime time, Recipe recipe) {
      List<MealTime> sortedMealTimes = allSelected.keys.sorted((a, b) => a.goesBefore(b) ? -1 : 1).toList();
      for (int i = 0; i < sortedMealTimes.length; i++) {
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

  Recipe? getValidRecipeForConfiguration({required int maxNumberOfTimesTheSameRecipeShouldBeUsed, required MenuConfiguration configuration, required Set<Recipe> candidates, required bool needToBeStored, required List<Recipe> alreadySelected, required bool strictMealTime}) {
    Debug.log(
        "Verifying if there is a valid recipe for ${configuration.mealTime}. Candidates: ${candidates.map((e) => e.toShortString()).join(", ")}. MaxRepetitions: $maxNumberOfTimesTheSameRecipeShouldBeUsed. Need to be stored: $needToBeStored. Already selected: ${alreadySelected.map((e) => e.toShortString()).join(", ")}. Strict meal time: $strictMealTime");
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

    // Prioritize the recipes that have been selected already (and can be stored)
    List<Recipe> shuffledCandidates = candidates.shuffled(Random(seed)).toList();
    List<Recipe> uniqueCandidatesAlreadySelected = alreadySelected.shuffled(Random(seed)).toSet().toList();
    for (Recipe recipe in uniqueCandidatesAlreadySelected) {
      if (recipe.canBeStored && shuffledCandidates.contains(recipe)) {
        shuffledCandidates.remove(recipe);
        shuffledCandidates.insert(0, recipe);
      }
      // Prioritize those candidates that have not been selected too many times
      int timesSelected = alreadySelected.where((element) => element == recipe).length;
      if (timesSelected >= maxNumberOfTimesTheSameRecipeShouldBeUsed) {
        shuffledCandidates.remove(recipe);
        shuffledCandidates.add(recipe);
      }
    }

    // Get the for each type of recipe
    List<Recipe> carbsCandidates = shuffledCandidates.where((element) => element.carbs).toList();
    List<Recipe> proteinsCandidates = shuffledCandidates.where((element) => element.proteins).toList();
    List<Recipe> vegetablesCandidates = shuffledCandidates.where((element) => element.vegetables).toList();
    List<Recipe> otherCandidates = shuffledCandidates.where((element) => !element.carbs && !element.proteins && !element.vegetables).toList();
    Recipe? carbsRecipe = carbsCandidates.firstWhereOrNull((recipe) => recipe.fitsConfiguration(configuration, needToBeStored: needToBeStored, strictMealTime: strictMealTime));
    Recipe? proteinsRecipe = proteinsCandidates.firstWhereOrNull((recipe) => recipe.fitsConfiguration(configuration, needToBeStored: needToBeStored, strictMealTime: strictMealTime));
    Recipe? vegetablesRecipe = vegetablesCandidates.firstWhereOrNull((recipe) => recipe.fitsConfiguration(configuration, needToBeStored: needToBeStored, strictMealTime: strictMealTime));
    Recipe? otherRecipe = otherCandidates.firstWhereOrNull((recipe) => recipe.fitsConfiguration(configuration, needToBeStored: needToBeStored, strictMealTime: strictMealTime));

    // Get the recipes prioritizing the least selected ones
    List<int> fromLeastSelectedToMostSelectedIds = [1, 2, 3].sorted((a, b) {
      return getSelectedAmountById(a).compareTo(getSelectedAmountById(b));
    }).toList();
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
    return recipesByLeastSelected.firstWhereOrNull((recipe) => recipe != null);
  }

  List<MenuConfiguration> getPreviousMomentConfigurations({required MenuConfiguration previousThan, required List<MenuConfiguration> possibleConfigurations}) {
    List<MenuConfiguration> sortedConfigurations = [previousThan, ...possibleConfigurations].sorted((a, b) => a.goesBefore(b) ? -1 : 1).toList();
    int previousThanIndex = sortedConfigurations.indexOf(previousThan);
    return sortedConfigurations.sublist(0, previousThanIndex);
  }

  Map<MealTime, Recipe?> getRecipesFor({required List<MenuConfiguration> configurationsToFindRecipesFor, required Set<Recipe> recipesToConsider}) {
    Map<MealTime, Recipe?> result = {};

    configurationsToFindRecipesFor.shuffle(Random(seed));
    int configurationsThatCanBeCookedAtTheSpot = configurationsToFindRecipesFor.where((element) => element.canBeCookedAtTheSpot).length;
    int configurationsThatCannotBeCookedAtTheSpot = configurationsToFindRecipesFor.where((element) => !element.canBeCookedAtTheSpot).length;
    int totalConfigurations = configurationsToFindRecipesFor.length;
    double percentageOfConfigurationsThatCanBeCookedAtTheSpot = configurationsThatCanBeCookedAtTheSpot / totalConfigurations;
    int maxNumberOfTimesTheSameRecipeShouldBeUsed = (totalConfigurations * (percentageOfConfigurationsThatCanBeCookedAtTheSpot / 3.1)).ceil();
    List<Recipe> selectedRecipesWithRepetitions = result.values.whereType<Recipe>().toList();
    Debug.log("Number of selected reicpes with repetitions: ${selectedRecipesWithRepetitions.length}");
    int numberOfTimesTheRecipeHasBeenUsed(Recipe recipe) => selectedRecipesWithRepetitions.where((element) => element == recipe).length;
    Recipe? recipeFromTheSelectedOnesThatHasBeenSelectedTheLeast() => selectedRecipesWithRepetitions.isEmpty ? null : selectedRecipesWithRepetitions.reduce((value, element) => numberOfTimesTheRecipeHasBeenUsed(value) < numberOfTimesTheRecipeHasBeenUsed(element) ? value : element);

    Debug.logDev("Starting to look for recipes.\n"
        "canBeCookedAtTheSpot: $configurationsThatCanBeCookedAtTheSpot\n"
        "cannotBeCookedAtTheSpot: $configurationsThatCannotBeCookedAtTheSpot\n"
        "totalConfigurations: $totalConfigurations\n"
        "percentageOfConfigurationsThatCanBeCookedAtTheSpot: $percentageOfConfigurationsThatCanBeCookedAtTheSpot\n"
        "maxNumberOfTimesTheSameRecipeCanBeUsed: $maxNumberOfTimesTheSameRecipeShouldBeUsed\n"
        "numberOfTimesTheRecipeHasBeenUsed: $numberOfTimesTheRecipeHasBeenUsed\n"
        "recipeFromTheSelectedOnesThatHasBeenSelectedTheLeast: ${recipeFromTheSelectedOnesThatHasBeenSelectedTheLeast()?.toShortString()}");

    // Sort by available cooking time
    List<MenuConfiguration> configsByAvailableTime = [...configurationsToFindRecipesFor].sorted((a, b) => a.availableCookingTimeMinutes.compareTo(b.availableCookingTimeMinutes)).toList();
    for (int i = 0; i < configsByAvailableTime.length; i++) {
      MenuConfiguration configWithTheLeastAvailableTime = configsByAvailableTime[i];
      Debug.logDev("Looking for recipe for ${configWithTheLeastAvailableTime.mealTime} (${configWithTheLeastAvailableTime.availableCookingTimeMinutes} minutes available)");

      if (result.containsKey(configWithTheLeastAvailableTime.mealTime)) {
        // The configuration has already been set (maybe by a configuration with lower available cooking time)
        Debug.logUpdate("Configuration already set");
        continue;
      }

      // Get the recipe for the configuration with the least available cooking time
      Recipe? recipe = getValidRecipeForConfiguration(
          maxNumberOfTimesTheSameRecipeShouldBeUsed: maxNumberOfTimesTheSameRecipeShouldBeUsed, strictMealTime: true, configuration: configWithTheLeastAvailableTime, candidates: recipesToConsider, needToBeStored: false, alreadySelected: result.values.whereType<Recipe>().toList());
      if (recipe != null) {
        // Valid recipe found. Set it for the configuration
        Debug.logSuccess("Valid recipe found straight away for ${configWithTheLeastAvailableTime.mealTime}");
        result[configWithTheLeastAvailableTime.mealTime] = recipe;
      } else {
        Debug.log("No valid recipe found straight away for ${configWithTheLeastAvailableTime.mealTime}");
        // Valid recipe not found. Try to get the recipe for the nearest previous moment
        List<MenuConfiguration> possibleMoments = [...configurationsToFindRecipesFor].sublist(i);

        // Remove those that can not cook at the spot
        possibleMoments.removeWhere((element) => !element.canBeCookedAtTheSpot);

        // List all the configuration that are form moments previous than the current one
        List<MenuConfiguration> previousMomentConfigurations = getPreviousMomentConfigurations(previousThan: configWithTheLeastAvailableTime, possibleConfigurations: configurationsToFindRecipesFor);

        // Filter out the configurations that have already been set
        possibleMoments.removeWhere((MenuConfiguration config) => result.containsKey(config.mealTime));

        Debug.logUpdate("Looking for recipe in other (previous) moments... ${previousMomentConfigurations.length} previous moments available: ${previousMomentConfigurations.map((e) => e.mealTime).join(", ")}");

        // Check if all the previous moments have already been set
        List<MenuConfiguration> previousMomentsWithAlreadySelectedMeal = previousMomentConfigurations.where((element) => result.containsKey(element.mealTime)).toList();
        if (previousMomentsWithAlreadySelectedMeal.length >= previousMomentConfigurations.length) {
          Debug.logUpdate("All the previous moments have already been set");
          // All the previous moments have already been set.
          Recipe? recipe = recipeFromTheSelectedOnesThatHasBeenSelectedTheLeast();
          if (recipe != null) {
            result[configWithTheLeastAvailableTime.mealTime] = recipe;
          } else {
            // No recipe can be selected for this moment nor a previous one
          }
        } else {
          // There are previous moments that have not been set yet.
          Debug.log("There are previous moments that have not been set yet");
          // Remove the previous moments that have already been set
          previousMomentConfigurations.removeWhere((MenuConfiguration config) => result.containsKey(config.mealTime));
          Debug.log("Previous moments that have not been set yet (${previousMomentConfigurations.length}): ${previousMomentConfigurations.map((e) => e.mealTime).join(", ")}");

          while (previousMomentConfigurations.isNotEmpty) {
            // Select the previous moment configuration, being the one that is further away from the current moment (as early as possible)
            MenuConfiguration selectedPreviousMomentConfiguration = previousMomentConfigurations.first;
            Debug.log("Checking if it is possible to cook in ${selectedPreviousMomentConfiguration.mealTime}");
            // There is a previous moment. Try to get the recipe for it
            recipe = getValidRecipeForConfiguration(
                maxNumberOfTimesTheSameRecipeShouldBeUsed: maxNumberOfTimesTheSameRecipeShouldBeUsed, strictMealTime: false, configuration: selectedPreviousMomentConfiguration, candidates: recipesToConsider, needToBeStored: true, alreadySelected: result.values.whereType<Recipe>().toList());
            if (recipe == null) {
              Debug.logUpdate("It is not possible to cook in ${selectedPreviousMomentConfiguration.mealTime}");
              // Valid recipe not found for the previous moment. Remove the previous moment from the possible moments
              previousMomentConfigurations.remove(selectedPreviousMomentConfiguration);
            } else {
              Debug.logSuccess("Valid recipe found for ${selectedPreviousMomentConfiguration.mealTime}");
              // Valid recipe found for the previous moment.
              if (!result.values.contains(recipe)) {
                // The recipe has not been selected yet. Set it for the configuration, otherwise, keep the one that has already been selected
                result[selectedPreviousMomentConfiguration.mealTime] = recipe;
              }
              result[configWithTheLeastAvailableTime.mealTime] = recipe;
              break;
            }
          }
        }
      }
    }

    // Fill the gaps
    // Filter out the configurations that have already been set and those that have not
    Set<MenuConfiguration> configurationsThatHaveBeenSet = {};
    Set<MenuConfiguration> configurationsThatHaveNotBeenSet = {};
    for (MenuConfiguration configuration in configurationsToFindRecipesFor) {
      Recipe? recipe = result[configuration.mealTime];
      if (recipe != null) {
        configurationsThatHaveBeenSet.add(configuration);
      } else {
        configurationsThatHaveNotBeenSet.add(configuration);
      }
    }
    // For each of the configurations that have not been set, try to get a recipe from the previous moments
    for (MenuConfiguration configuration in configurationsThatHaveNotBeenSet) {
      Debug.log("Trying to fill the gap for ${configuration.mealTime}", signature: "🔎");
      // Get the previous moments from the configurations that have already been set
      List<MenuConfiguration> previousMealTimes = getPreviousMomentConfigurations(previousThan: configuration, possibleConfigurations: configurationsThatHaveBeenSet.toList());
      if (previousMealTimes.isNotEmpty) {
        // Get the recipes that have already been selected for the previous moments to consider them as candidates for the current configuration (missing a recipe)
        Set<Recipe> recipesToConsider = {};
        for (MenuConfiguration previousMealTime in previousMealTimes) {
          Recipe? recipe = result[previousMealTime.mealTime];
          if (recipe != null && recipe.canBeStored) {
            recipesToConsider.add(recipe);
          }
        }
        // Get a valid recipe for the configuration from the previous moments
        if (recipesToConsider.isNotEmpty) {
          Recipe? recipe = getValidRecipeForConfiguration(
            maxNumberOfTimesTheSameRecipeShouldBeUsed: maxNumberOfTimesTheSameRecipeShouldBeUsed,
            strictMealTime: false,
            configuration: configuration.copyWith(availableCookingTimeMinutes: 24 * 60),
            candidates: recipesToConsider,
            needToBeStored: true,
            alreadySelected: result.values.whereType<Recipe>().toList(),
          );
          if (recipe != null) {
            result[configuration.mealTime] = recipe;
          } else {
            Debug.logWarning(
                true,
                "No recipe found for ${configuration.mealTime} from the previous moments.\n"
                "Previous moments: ${previousMealTimes.map((e) => e.mealTime).join(", ")}\n"
                "Recipes to consider: ${recipesToConsider.map((e) => e.toShortString()).join(", ")}\n"
                "Already selected recipes: ${result.values.whereType<Recipe>().map((e) => e.toShortString()).join(", ")}\n"
                "Configurations that have been set: ${configurationsThatHaveBeenSet.map((e) => e.mealTime).join(", ")}\n"
                "Configurations that have not been set: ${configurationsThatHaveNotBeenSet.map((e) => e.mealTime).join(", ")}\n"
                "",
                asAssertion: false);
          }
        } else {
          Debug.log("No recipes to consider for ${configuration.mealTime}", signature: "🦢");
        }
      } else {
        Debug.log("No previous moments found for ${configuration.mealTime}", signature: "🫗");
      }
    }

    return result;
  }
}
