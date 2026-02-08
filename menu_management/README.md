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
    + [Common Development Tasks](#common-development-tasks)
  * [Project Guidelines](#project-guidelines)
    + [Architecture Overview](#architecture-overview)
    + [Directory Structure](#directory-structure)
    + [State Management](#state-management)
    + [Data Models](#data-models)
    + [Persistency Strategy](#persistency-strategy)
    + [Code Standards](#code-standards)
  * [Key Design Decisions](#key-design-decisions)
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

The algorithm in `MenuGenerator.generate()` optimizes recipe selection using these strategies:

**Phase 1: Separate Breakfast and Meal Generation**
- Generates breakfasts separately from lunch/dinner meals
- Shuffles available recipes with a configurable seed for variety

**Phase 2: Recipe Selection Priority**

For each meal time (sorted by available cooking time, least to most):

1. **Direct Assignment** (Strictest)
   - Try to find a recipe that:
     - Fits the available cooking time
     - Doesn't need to be stored (cook at the spot)
     - Matches the strict meal time (lunch recipes for lunch, dinner for dinner)
     - Balances nutritional variety

2. **Previous Cooking Opportunity** (Fallback)
   - If no direct recipe fits (e.g., 0 minutes available):
     - Look for earlier meals with cooking time available
     - Select a storable recipe that can be cooked in advance
     - Assign the same recipe to both time slots
     - First occurrence gets yield > 0, subsequent uses get yield = 0

3. **Nutritional Balance**
   - Tracks how many times each nutritional type (carbs, proteins, vegetables) has been selected
   - Prioritizes the **least selected** nutritional types
   - For recipes already selected, prioritizes those selected fewer times (up to a maximum repetition threshold)

4. **Yield Optimization**
   - After recipe assignment, runs `copyWithUpdatedYields()` to calculate correct yields:
     - For storable recipes: first occurrence gets yield = total number of times the recipe appears
     - Subsequent occurrences get yield = 0 (eating leftovers)
     - Non-storable recipes always get yield = 1

**Key Variables:**
- `maxNumberOfTimesTheSameRecipeShouldBeUsed`: Calculated based on the percentage of meals that can be cooked at the spot (approximately totalMeals × percentageCanCook / 3.1)
- `strictMealTime`: When true, lunch recipes only for lunch, dinner only for dinner; when false (for stored meals), either can be used

**Recipe Filtering:**
- Recipe must be included in menu generation (`includeInMenuGeneration == true`)
- Recipe must fit configuration constraints (storage requirement, cooking time, meal time)
- Recipe nutritional flags (carbs, proteins, vegetables) must match selection strategy

### Multi-Step Recipes with Inputs/Outputs

For complex recipes with intermediate steps, the app supports tracking intermediate results:

**Example: Pasta Bolognese**
1. **Instruction 1**: Dice onions and garlic
   - Ingredients: 1 onion, 2 garlic cloves
   - Outputs: Result("diced-aromatics", "Diced onions and garlic")
2. **Instruction 2**: Cook sauce
   - Ingredients: 400g ground beef, 1 can tomatoes
   - Inputs: ["diced-aromatics"] (references the output from Instruction 1)
   - Outputs: Result("bolognese-sauce", "Cooked bolognese sauce")
3. **Instruction 3**: Cook pasta
   - Ingredients: 300g pasta
   - Outputs: Result("cooked-pasta", "Cooked pasta")
4. **Instruction 4**: Combine
   - Inputs: ["bolognese-sauce", "cooked-pasta"]
   - Description: Mix pasta with sauce and serve

**Key Features:**
- `RecipesProvider.getRecipeInputsAvailability()`: Ensures an instruction can only use outputs from previous instructions
- Prevents circular dependencies (instruction cannot use its own outputs)
- Helps organize complex recipes into logical, ordered steps
- UI validates that inputs reference existing outputs from earlier instructions

### Cook Mode (Play Recipe)

The app provides a step-by-step cooking guide accessible via the **play button** (▶) on the recipe details page. This feature helps users follow a recipe hands-free, one instruction at a time.

**Features:**

| Feature | Description |
|---------|-------------|
| **Servings selector** | Adjust the number of servings in the top bar; all ingredient quantities scale automatically (base recipe = 1 serving) |
| **Step-by-step navigation** | View one instruction at a time with a progress indicator; tap previous/next preview cards to navigate |
| **Ingredient list** | Each step shows its required ingredients with adjusted quantities and any inputs from previous steps |
| **Input references** | Inputs from earlier steps appear visually distinct (tertiary color); tapping one opens a dialog with the source step summary and a button to jump to it |
| **Step outputs** | Intermediate results produced by the current step are displayed at the end of the instruction card |
| **Cooking timers** | If a step has cooking time, a timer can be started; timers persist across step navigation and notify the user with a snackbar when finished |
| **Multi-timer tracking** | Active timers from other steps are visible below the current step's timer, showing remaining time with a cancel button; tapping navigates to that step |
| **Exit warning** | If timers are running and the user tries to leave, a confirmation dialog warns that all timers will be cancelled |

**UI Layout (top to bottom):**
1. App bar with recipe name and servings selector
2. Progress indicator (step N of M)
3. Ingredients for the current step (inputs first, then regular ingredients)
4. Current instruction card with working/cooking time chips and outputs
5. Timer controls for the current step
6. Other active timers (from different steps)
7. Previous and next step preview cards

**Implementation:**
- `PlayRecipePage` (`lib/recipes/widgets/play_recipe_page.dart`) — a `StatefulWidget` opened via `Navigator.push` from the recipes page
- Timers are managed in-memory and are **not** persisted; leaving the page cancels all timers
- No new dependencies are required; the feature uses Material 3 components and the existing `flutter_essentials` library

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

### Common Development Tasks

**Adding a New Ingredient:**
```dart
Ingredient newIngredient = Ingredient(
  id: uuid.v4(),
  name: "Tomatoes"
);
IngredientsProvider.addOrUpdate(newIngredient: newIngredient);
```

**Creating a Recipe:**
```dart
Recipe recipe = Recipe(
  id: uuid.v4(),
  name: "Tomato Soup",
  instructions: [
    Instruction(
      id: uuid.v4(),
      ingredientsUsed: [
        IngredientUsage(
          ingredient: tomatoIngredientId,
          quantity: Quantity(amount: 500, unit: Unit.grams)
        )
      ],
      workingTimeMinutes: 10,
      cookingTimeMinutes: 20,
      description: "Chop and cook tomatoes"
    )
  ],
  carbs: false,
  proteins: false,
  vegetables: true,
  type: RecipeType.meal,
  canBeStored: true
);
RecipesProvider.addOrUpdate(newRecipe: recipe);
```

**Generating a Menu:**
```dart
Menu menu = MenuProvider.generateMenu(initialSeed: 42);
// Change seed to get different recipe combinations
Menu alternativeMenu = MenuProvider.generateMenu(initialSeed: 123);
```

**Accessing Shopping List:**
```dart
Menu menu = /* generated menu */;
Map<String, List<Quantity>> shoppingList = menu.allIngredients;
// shoppingList is a map: ingredientId -> List<Quantity>
// Multiple quantities per ingredient if different units are used
```

## Project Guidelines

### Architecture Overview

The app follows a **Provider-based architecture** with immutable models:

```
┌─────────────────────────────────────────────────────────────┐
│  UI Layer (Widgets)                                         │
│  ├── Hub - Main navigation rail with three sections:        │
│  │   ├── IngredientsPage - Browse and manage ingredients    │
│  │   ├── RecipesPage - Create and edit recipes              │
│  │   └── MenuConfigurationPage - Configure and generate menu│
│  └── ShoppingPage - Generated shopping list (from menu)     │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  State Management (Provider Pattern)                        │
│  ├── IngredientsProvider - Manages ingredient list          │
│  ├── RecipesProvider - Manages recipes and instructions     │
│  └── MenuProvider - Holds menu configurations and generator │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Data Layer (Freezed Models)                                │
│  ├── Ingredient - id, name                                  │
│  ├── IngredientUsage - ingredient reference + quantity      │
│  ├── Quantity - amount + unit                               │
│  ├── Instruction - ingredients, times, description, I/O     │
│  ├── Recipe - instructions, nutritional flags, storage      │
│  ├── Meal - mealTime + cooking + people                     │
│  ├── Menu - list of meals with yield calculation            │
│  └── MenuConfiguration - mealTime + requirements            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  Persistency - File-based storage (.tsr files)              │
└─────────────────────────────────────────────────────────────┘
```

### Directory Structure

```
lib/
├── main.dart                 # Entry point with MultiProvider setup
├── hub.dart                  # Main navigation rail (Ingredients/Recipes/Menu)
├── persistency.dart          # Save/load data to .tsr files
├── flutter_essentials/       # Utility extensions and reusable widgets
│   ├── library.dart          # Barrel file for utilities
│   └── utils/                # Extension methods, debug helpers
├── ingredients/
│   ├── ingredients_provider.dart  # Ingredient state management
│   ├── models/
│   │   └── ingredient.dart        # Ingredient model (Freezed)
│   └── widgets/
│       └── ingredients_page.dart  # Ingredient management UI
├── recipes/
│   ├── recipes_provider.dart      # Recipe state management
│   ├── enums/
│   │   ├── recipe_type.dart       # breakfast, meal, snack, dessert
│   │   └── unit.dart              # grams, centiliters, pieces, etc.
│   ├── models/
│   │   ├── recipe.dart            # Recipe model with instructions
│   │   ├── instruction.dart       # Recipe step with ingredients
│   │   ├── ingredient_usage.dart  # Ingredient + quantity
│   │   ├── quantity.dart          # Amount + unit
│   │   └── result.dart            # Intermediate cooking result
│   └── widgets/
│       ├── recipes_page.dart      # Recipe management UI
│       └── play_recipe_page.dart  # Step-by-step cooking guide with timers
├── menu/
│   ├── menu_provider.dart         # Menu configuration state
│   ├── menu_generator.dart        # Core menu generation algorithm
│   ├── enums/
│   │   ├── meal_type.dart         # breakfast, lunch, dinner
│   │   └── week_day.dart          # Days of the week
│   ├── models/
│   │   ├── menu.dart              # Weekly menu with meals
│   │   ├── meal.dart              # Single meal instance
│   │   ├── meal_time.dart         # Weekday + meal type
│   │   ├── menu_configuration.dart # Meal requirements
│   │   └── cooking.dart           # Recipe + yield
│   └── widgets/
│       ├── menu_configuration_page.dart  # Configure and generate
│       └── menu_page.dart                # Display generated menu
└── shopping/
    ├── shopping_page.dart         # Shopping list UI
    └── shopping_ingredient.dart   # Shopping list item widget
```

**Key modules:**
- `ingredients/` - Simple ingredient management (create, read, update, delete)
- `recipes/` - Complex recipe creation with multi-step instructions, ingredient tracking, and time management
- `menu/` - Menu configuration and intelligent menu generation algorithm
- `shopping/` - Auto-generated shopping lists from menus with owned quantity tracking

### State Management

**Provider Pattern with Singletons:**

Each provider uses the singleton pattern to ensure a single source of truth:

```dart
// Access singleton directly for static methods
IngredientsProvider.addOrUpdate(newIngredient: ingredient);
RecipesProvider.remove(recipeId: id);

// Access via context for listening to changes
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Ingredient> ingredients = 
      Provider.of<IngredientsProvider>(context).ingredients;
    
    return ListView.builder(
      itemCount: ingredients.length,
      itemBuilder: (context, index) => Text(ingredients[index].name),
    );
  }
}

// Or use helper method for listening to specific items
Widget build(BuildContext context) {
  Recipe recipe = RecipesProvider.listenableOf(context, recipeId);
  return Text(recipe.name);
}
```

**Provider Responsibilities:**
- `IngredientsProvider`: CRUD operations for ingredients, search history
- `RecipesProvider`: CRUD for recipes and instructions, recipe filtering by type/nutrition, result/input tracking for multi-step recipes
- `MenuProvider`: Holds 21 MenuConfigurations (7 days × 3 meals), triggers menu generation

**Data Flow:**
1. User modifies data through widgets
2. Widget calls static provider method (e.g., `RecipesProvider.addOrUpdate()`)
3. Provider updates internal state and calls `notifyListeners()`
4. All widgets listening to the provider rebuild with new data

### Data Models

All models use **Freezed** for immutability, copyWith, JSON serialization, and equality:

**Core Models:**

```dart
// Ingredient - Basic food item
Ingredient(id: String, name: String)

// IngredientUsage - Links ingredient to instruction with quantity
IngredientUsage(ingredient: String, quantity: Quantity)

// Quantity - Measurement
Quantity(amount: double, unit: Unit)

// Instruction - Recipe step
Instruction(
  id: String,
  ingredientsUsed: List<IngredientUsage>,
  workingTimeMinutes: int,
  cookingTimeMinutes: int,
  description: String,
  outputs: List<Result>,  // For multi-step recipes
  inputs: List<String>    // References to other outputs
)

// Recipe - Complete recipe
Recipe(
  id: String,
  name: String,
  instructions: List<Instruction>,
  carbs: bool,            // Nutritional flags
  proteins: bool,
  vegetables: bool,
  type: RecipeType,       // breakfast, meal, snack, dessert
  lunch: bool,            // Meal time suitability
  dinner: bool,
  canBeStored: bool,      // Can be cooked in advance
  includeInMenuGeneration: bool
)

// Meal - Instance of a meal
Meal(
  mealTime: MealTime,
  cooking: Cooking?,      // null if no meal required
  people: int
)

// Cooking - Recipe assignment with yield
Cooking(
  recipe: Recipe,
  yield: int              // How many servings to prepare (0 = leftovers)
)

// Menu - Weekly plan
Menu(meals: List<Meal>)
  .allIngredients         // Aggregated shopping list
  .copyWithUpdatedYields()  // Recalculates yields for storable recipes
```

**Business Logic Methods:**

Models include business logic methods:
- `Recipe.fitsConfiguration()`: Check if recipe matches meal requirements
- `Menu.copyWithUpdatedRecipe()`: Update a meal's recipe and recalculate yields
- `Menu.copyWithUpdatedYields()`: Calculate yields based on recipe reuse
- `Menu.allIngredients`: Aggregate all ingredients across meals (respects yields)
- `MenuConfiguration.canBeCookedAtTheSpot`: Derived from time availability

### Persistency Strategy

**File-based storage** using custom `.tsr` (or `.json`) format:

```dart
// Save (desktop only - mobile doesn't support FilePicker.saveFile)
Persistency.saveData()  // Opens file picker, saves ingredients + recipes

// Load
Persistency.loadData(
  ingredientsProvider: provider1,
  recipesProvider: provider2
)  // Opens file picker, loads data into providers
```

**File Structure:**
```json
{
  "Ingredients": [
    {"id": "...", "name": "..."},
    ...
  ],
  "Recipes": [
    {
      "id": "...", 
      "name": "...",
      "instructions": [...],
      ...
    },
    ...
  ]
}
```

**Important Notes:**
- Data is **not** automatically saved - users must manually save via the save button
- Data is **not** automatically loaded in debug mode (see `main.dart`)
- Menu configurations and generated menus are **not** persisted (generated on-demand)
- Mobile platforms (iOS/Android) cannot save data (FilePicker limitation)

### Code Standards

**General:**
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use explicit type annotations for all variables, parameters, and return types
- Use Freezed for all data models to ensure immutability
- Document complex business logic with comments

**Provider Pattern:**
- Use singleton pattern for all providers
- Provide static methods for mutations (e.g., `addOrUpdate`, `remove`)
- Provide `listenableOf` methods for accessing single items with context
- Always call `notifyListeners()` after state changes

**Model Guidelines:**
- Use `const` constructors where possible
- Add empty `const Model._()` constructor to enable custom methods
- Include business logic methods directly in models (e.g., `fitsConfiguration`)
- Use Freezed's `copyWith` for immutable updates
- Prefer derived getters over storing redundant state

**Naming Conventions:**
- Models: PascalCase (e.g., `Ingredient`, `MenuConfiguration`)
- Providers: `<Feature>Provider` (e.g., `IngredientsProvider`)
- Files: snake_case matching the class name
- Enums: PascalCase with lowercase values

**Performance Considerations:**
- Provider rebuilds can be expensive - use `listen: false` when reading without reacting to changes
- Menu generation is O(n²) in worst case - acceptable for weekly menus (~21 meals)
- Shopping list aggregation iterates all meals × instructions × ingredients - optimize if scaling beyond weekly menus

**Comment Markers:**
- `//TODO`: Planned improvements or features to be implemented
- No formal testing suite currently implemented (widget_test.dart is template only)

## Key Design Decisions

**Why Provider instead of other state management?**
- Simple, built-in Flutter solution without additional dependencies
- Singleton pattern ensures single source of truth
- Sufficient for desktop app without complex asynchronous state

**Why Freezed for models?**
- Immutability prevents accidental state mutations
- Generated `copyWith` methods simplify updates
- Built-in equality and toString methods
- JSON serialization comes free

**Why file-based persistence instead of database?**
- Desktop app with single user - no need for multi-user database
- User maintains full control over their data files
- Easy backup and sharing (email a .tsr file)
- Human-readable JSON format for debugging

**Why separate breakfast from meals in generation?**
- Breakfast recipes rarely work for lunch/dinner and vice versa
- Simplifies algorithm by reducing recipe pool size
- Better user experience with appropriate meal types

**Why calculate yields after generation?**
- Yield depends on total recipe reuse count
- Can't know reuse count until full menu is generated
- Post-processing step cleaner than tracking during generation

**Why prioritize least-selected nutritional types?**
- Ensures balanced diet over the week
- Prevents menu of all carbs or all proteins
- Mimics natural human meal planning intuition

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

