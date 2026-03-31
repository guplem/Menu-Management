# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Living Document

This file is self-improving. When you discover something worth recording, update it immediately:

| Discovery | Where to write |
|---|---|
| Project-specific constraint, gotcha, or pattern | This file |
| Cross-project preference or pattern | `~/.claude/CLAUDE.md` |
| Architectural decision with rationale | New ADR in `adr/` and index it here |
| Wrong or outdated instruction | Correct it in place |

Document non-obvious behavior -- things a competent agent would get wrong without an explicit rule. Skip anything easily discoverable via normal code reading.

## Documentation Organization

| File | Audience | Content |
|------|----------|---------|
| `README.md` | Humans | What the project is, how to install/run/deploy, features, troubleshooting |
| `CLAUDE.md` | AI agents | Architecture, patterns, coding rules, gotchas, procedures |

No duplication between them. If setup instructions are in README, CLAUDE.md only references them or includes a quick command table.

## Project Overview

Flutter desktop app for weekly meal planning. Users create ingredients, build recipes, configure time constraints per meal slot, and generate optimized weekly menus with auto-aggregated shopping lists.

All Flutter source code lives under `menu_management/`.

## Commands

| Task | Command | Notes |
|------|---------|-------|
| Run app (Windows) | `cd menu_management && flutter run -d windows` | Also supports `-d linux`, `-d macos` |
| Analyze | `cd menu_management && flutter analyze` | Enforced lint rules in `analysis_options.yaml` |
| Code generation | `cd menu_management && dart run build_runner build --delete-conflicting-outputs` | Required after changing any Freezed/json_serializable model |
| Code gen (watch) | `cd menu_management && dart run build_runner watch --delete-conflicting-outputs` | |
| Build release | `cd menu_management && flutter build windows` | |
| Build + copy to Desktop | `cd menu_management && ./build_and_copy.bat` | Windows only; copies portable build to Desktop |
| Run single test | `cd menu_management && flutter test test/<file>.dart` | No active test suite currently |
| List devices | `flutter devices` | |

## Architecture

### Three-Layer Structure

```
UI (Widgets)  -->  State (Providers)  -->  Data (Freezed Models)
```

- **UI**: Stateful widgets organized by feature domain
- **State**: Provider pattern with singleton providers (`IngredientsProvider`, `RecipesProvider`, `MenuProvider`)
- **Data**: Freezed immutable models with JSON serialization; business logic lives on the models themselves

### Navigation

`hub.dart` is the central navigation rail with three main sections (Ingredients, Recipes, Menu) plus load/save buttons. `ShoppingPage` is accessible after menu generation.

### Feature Domains

| Domain | Provider | Key Models | Purpose |
|--------|----------|------------|---------|
| `ingredients/` | `IngredientsProvider` | `Ingredient` | CRUD for food items |
| `recipes/` | `RecipesProvider` | `Recipe`, `Instruction`, `IngredientUsage`, `Quantity`, `Result` | Recipe management with multi-step instructions, inputs/outputs |
| `menu/` | `MenuProvider` | `MultiWeekMenu`, `Menu`, `Meal`, `MealTime`, `Cooking`, `MenuConfiguration` | Multi-week menus (each week = 21 meal slots), generation algorithm |
| `shopping/` | (derived) | `ShoppingIngredient` | Aggregated shopping list from generated menu |
| `theme/` | - | `DynamicTheme`, `ThemeCustom` | Material 3 theming |

### Menu Generation Algorithm

Core logic in `menu_generator.dart`. Multi-phase assignment with priority ordering, yield calculation for leftovers, and time-constraint fitting. See [ADR 0004](adr/0004-menu-generation-algorithm.md) for detailed algorithm documentation.

### Persistence

`persistency.dart` handles file I/O. Data is saved/loaded as `.tsr` files (JSON-based). On release builds, the app auto-loads the last saved file. Save is unavailable on iOS/Android due to `FilePicker` limitations.

- Data is **not** automatically saved -- users must manually save via the save button
- Data is **not** automatically loaded in debug mode (see `main.dart`)
- Menu configurations and generated menus are **not** persisted (generated on-demand)
- `.tsr` file structure: JSON with top-level `"Ingredients"` and `"Recipes"` arrays

## Pattern Scout (mandatory)

Before implementing any new feature, widget, provider, or model, run the `pattern-scout` agent (`.claude/agents/pattern-scout.md`). It analyzes the codebase for similar implementations and reports established patterns, naming conventions, file locations, and structure. Treat its output as the baseline to follow unless you have a concrete reason to deviate, and explain that reasoning when you do.

## Test-Driven Development (mandatory)

All changes must follow red-green TDD:

1. **RED**: Write failing tests first that describe the expected behavior.
2. **GREEN**: Write the minimum code to make the tests pass.
3. Repeat for each incremental behavior.

Tests live in `menu_management/test/`. Run with `cd menu_management && flutter test test/<file>.dart`.

This applies to new features, bug fixes, and refactors. Do not write production code without a failing test driving it.

## Key Patterns

### Provider Pattern
- Each provider is a singleton `ChangeNotifier` with static mutation methods (`addOrUpdate`, `remove`)
- Use `listenableOf()` helper for context-based listening to individual items
- Always call `notifyListeners()` after state changes
- Use `listen: false` when reading without reacting to changes (avoids expensive rebuilds)
- Provider responsibilities:
  - `IngredientsProvider`: CRUD for ingredients, search history
  - `RecipesProvider`: CRUD for recipes/instructions, filtering by type/nutrition, result/input tracking
  - `MenuProvider`: Holds 21 MenuConfigurations (7 days x 3 meals), triggers menu generation
- Data flow: Widget -> static provider method -> provider updates state -> `notifyListeners()` -> listening widgets rebuild

### Freezed Models
- All data models use Freezed for immutability, `copyWith`, equality, and JSON serialization
- Generated files (`*.freezed.dart`, `*.g.dart`) are excluded from analysis
- Business logic methods are embedded directly on models (e.g., `Recipe.fitsConfiguration()`, `Menu.copyWithUpdatedYields()`)
- Use `const` constructors where possible
- Add empty `const Model._()` constructor to enable custom methods
- Prefer derived getters over storing redundant state
- Key business logic methods:
  - `Recipe.fitsConfiguration()`: Check if recipe matches meal requirements
  - `Menu.copyWithUpdatedRecipe()`: Update a meal's recipe and recalculate yields
  - `Menu.copyWithUpdatedYields()`: Calculate yields based on recipe reuse
  - `Menu.allIngredients`: Aggregate all ingredients across meals (respects yields)
  - `MenuConfiguration.canBeCookedAtTheSpot`: Derived from time availability

### Search
- `normalizeForSearch()` extension (in `flutter_essentials/`) with optional space removal
- Applied consistently to ingredient and recipe search/filter

### Utility Library
`flutter_essentials/` contains shared extensions, widgets, and debug helpers used across all features.

## Code Standards

From `analysis_options.yaml`:
- **Double quotes** (`prefer_double_quotes`)
- **Package imports only** (`always_use_package_imports`, no relative lib imports)
- **Explicit types** on public APIs, return types, and init formals
- **Page width**: 150 characters
- `use_build_context_synchronously` is disabled (context.mounted checks used manually)
- Models: PascalCase (`Ingredient`, `MenuConfiguration`)
- Providers: `<Feature>Provider` (`IngredientsProvider`)
- Files: snake_case matching the class name
- Enums: PascalCase with lowercase values

## Architecture Decision Records (ADRs)

Stored in `adr/` at the repo root. Format: `NNNN-short-descriptive-title.md` with sequential numbering. Each ADR has three sections: Context, Decision, Consequences.

ADRs capture **why** decisions were made, not just what was built. This includes architectural choices, feature design rationale, goals and constraints that shaped the solution, and trade-offs considered. Write in plain text so a reader understands the reasoning without needing to read the code. ADRs are the place to record anything that would otherwise live only in someone's head.

| ADR | Topic |
|-----|-------|
| [0001](adr/0001-freezed-models-with-business-logic.md) | Freezed models with embedded business logic |
| [0002](adr/0002-singleton-provider-state-management.md) | Singleton Provider state management |
| [0003](adr/0003-tsr-file-persistence.md) | .tsr file-based persistence |
| [0004](adr/0004-menu-generation-algorithm.md) | Menu generation algorithm (phases, priority, yield, nutritional balance) |
| [0005](adr/0005-multi-step-recipes-with-inputs-outputs.md) | Multi-step recipes with inputs/outputs dependency chain |
| [0006](adr/0006-cook-mode-play-recipe.md) | Cook mode: step-by-step cooking guide with timers and scaling |
| [0007](adr/0007-flutter-essentials-as-local-library.md) | flutter_essentials as a local library directory, not a separate package |
| [0008](adr/0008-multi-week-menus.md) | Multi-week menus: MultiWeekMenu wraps List\<Menu\>, independent generation per week |

**When to consult ADRs:** Before changing state management, data models, persistence, or introducing new architectural patterns. Run the `adr-checker` agent (`.claude/agents/adr-checker.md`) in consult mode to find relevant ADRs.

**When to create/update ADRs:** After making decisions that change how the app is structured, how data flows, or how features are wired together. Run the `adr-checker` agent in maintain mode to determine if a new ADR is needed or an existing one should be updated.

## Gotchas

- After changing any Freezed model, you **must** run `dart run build_runner build --delete-conflicting-outputs` or the app will not compile.
- `*.g.dart` and `*.freezed.dart` are committed to the repo (no build step in CI).
- The `flutter_essentials/` library is a local package inside `lib/`, not a separate pub package.
- Platform target is desktop-first. Mobile platforms have limited save/load support.
