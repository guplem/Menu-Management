<!-- toc -->

- [Menu Management](#menu-management)
  * [Quick Start](#quick-start)
  * [How It Works](#how-it-works)
    + [Core Concepts](#core-concepts)
    + [Menu Generation Flow](#menu-generation-flow)
    + [Menu Generation Algorithm](#menu-generation-algorithm)
    + [Multi-Step Recipes with Inputs/Outputs](#multi-step-recipes-with-inputsoutputs)
    + [Cook Mode (Play Recipe)](#cook-mode-play-recipe)
  * [Contributing](#contributing)
    + [Software Requirements](#software-requirements)
    + [Setup](#setup)
    + [Running the Project](#running-the-project)
    + [Code Generation](#code-generation)
  * [Use Cases](#use-cases)

<!-- tocstop -->

# Menu Management

**Menu Management** is a Flutter desktop application that helps users plan weekly menus by intelligently generating meal plans based on available recipes, cooking time constraints, nutritional balance, and storage capabilities.

## Quick Start

1. **Create Ingredients**: Navigate to the Ingredients tab and add basic food items (e.g., "Chicken", "Rice", "Tomatoes")
2. **Create Recipes**: Go to the Recipes tab and create recipes with:
   - Basic information (name, type, nutritional flags)
   - Instructions with ingredients, working time, and cooking time
   - Meal time suitability and storage capability
3. **Configure Menu**: In the Menu tab, adjust available cooking time for each meal
4. **Generate Menu**: Click generate to create an optimized weekly menu
5. **Shopping List**: View the automatically generated shopping list with ingredient aggregation
6. **Save Data**: Use the save button in the navigation rail to persist your data to a `.tsr` file

## How It Works

### Core Concepts

| Concept | Description |
|---------|-------------|
| **Ingredient** | A basic food item with a unique ID and name used in recipes |
| **IngredientUsage** | Links an ingredient to a recipe instruction with a specific quantity (amount + unit) |
| **Instruction** | A step in a recipe with ingredients used, working time, cooking time, description, and optional inputs/outputs for multi-step recipes |
| **Recipe** | A collection of instructions with nutritional flags (carbs, proteins, vegetables), type (breakfast/meal/snack/dessert), meal time suitability (lunch/dinner), and storage capability |
| **Quantity** | A measurement consisting of an amount and a unit (grams, centiliters, pieces, tablespoons, teaspoons) |
| **Meal** | A specific eating occasion at a MealTime (weekday + meal type) with an assigned recipe, yield, and number of people |
| **Menu** | A complete weekly plan containing all meals with automatically calculated yields for storable recipes |
| **MenuConfiguration** | Settings for each meal time defining whether a meal is required and how much cooking time is available |
| **Result** | An intermediate cooking output from one instruction that can be used as input to another (e.g., "diced onions", "cooked pasta") for multi-step recipes |

### Menu Generation Flow

1. **Configure Meal Requirements**: User sets up weekly menu configurations specifying:
   - Which meals are required (breakfast, lunch, dinner for each day)
   - Available cooking time for each meal (0-60+ minutes)

2. **Manage Recipes**: User creates recipes with:
   - Instructions containing ingredients, working time, cooking time
   - Nutritional categorization (carbs, proteins, vegetables)
   - Recipe type (breakfast, meal, snack, dessert)
   - Meal time suitability (lunch and/or dinner)
   - Storage capability flag

3. **Generate Menu**: App produces an optimized weekly menu using the generation algorithm

4. **Review and Adjust**: User can:
   - View the complete menu by day
   - Manually modify recipe assignments for specific meals
   - Adjust number of people per meal
   - Regenerate with a different seed for variety

5. **Shopping List**: App automatically generates a shopping list by:
   - Aggregating all ingredients across the menu
   - Calculating yields for storable recipes (cook once, eat multiple times)
   - Combining quantities by ingredient and unit
   - Allowing users to mark owned quantities to calculate remaining amounts needed

### Menu Generation Algorithm

The algorithm in `MenuGenerator.generate()` optimizes recipe selection through multi-phase assignment with priority ordering, yield calculation for leftovers, nutritional balance tracking, and time-constraint fitting.

For full algorithm documentation, see [ADR 0004: Menu Generation Algorithm](../adr/0004-menu-generation-algorithm.md).

### Multi-Step Recipes with Inputs/Outputs

Complex recipes can have intermediate steps where the output of one instruction feeds into another. Each instruction can declare outputs (intermediate results like "diced onions") and inputs (references to outputs from previous instructions), creating an explicit dependency chain.

For design rationale and detailed examples, see [ADR 0005: Multi-Step Recipes](../adr/0005-multi-step-recipes-with-inputs-outputs.md).

### Cook Mode (Play Recipe)

The app provides a step-by-step cooking guide accessible via the **play button** on the recipe details page. It helps users follow a recipe hands-free with one instruction at a time, adjustable servings with automatic quantity scaling, and cooking timers with audio notifications.

For design rationale and UI layout details, see [ADR 0006: Cook Mode](../adr/0006-cook-mode-play-recipe.md).

## Contributing

### Software Requirements
- Flutter ^3.29.2
- Dart SDK >=3.10.0 <4.0.0
- Windows/Linux/macOS for desktop builds

### Setup
```bash
flutter doctor          # Verify Flutter installation
git clone <repository>  # Clone the repository
flutter pub get         # Install dependencies
```

### Running the Project

```bash
# Windows
flutter run -d windows

# Linux
flutter run -d linux

# macOS
flutter run -d macos

# List available devices
flutter devices
```

### Code Generation

The project uses Freezed for immutable data classes and JSON serialization:

```bash
# Generate all code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

This generates:
- `*.freezed.dart` files for immutable models with copyWith
- `*.g.dart` files for JSON serialization/deserialization

## Use Cases

**Weekly Meal Prep:**
- Set Monday-Friday lunches to 0 minutes cooking time
- App automatically schedules storable recipes for Sunday cooking
- One cooking session covers all weekday lunches

**Budget Shopping:**
- Generate menu for the week
- Export shopping list
- Buy only what's needed, minimize waste

**Dietary Restrictions:**
- Create recipes with nutritional flags
- Filter recipes during generation
- Ensure balanced nutrition across the week

**Recipe Organization:**
- Store all recipes in one place with detailed instructions
- Track cooking times for time management
- Categorize by meal type and nutritional content

**Variety Without Decision Fatigue:**
- Change generation seed to get different menu combinations
- Algorithm handles nutritional balance automatically
- No need to manually plan each meal

