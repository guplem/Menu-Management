# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Flutter desktop app for weekly meal planning. Users create ingredients, build recipes, configure time constraints per meal slot, and generate optimized weekly menus with auto-aggregated shopping lists. All Flutter source code lives under `menu_management/`.

Before implementing any non-trivial feature, delegate to the **pattern-scout** agent.

Before implementing features that touch state management, data models, persistence, menu generation, or app architecture, delegate to the **adr-checker** agent in **consult mode**. After such changes, delegate in **maintain mode**.

After writing or modifying code, delegate to the **test-runner** agent.

After completing changes that affect documented content, delegate to the **docs-checker** agent.

When the user's request is broad or exploratory, ask whether they'd like to run multi-agent research (`/research-agents`) before proceeding.

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

## Commands

| Task | Command | Notes |
|------|---------|-------|
| Run app (Windows) | `cd menu_management && flutter run -d windows` | Also supports `-d linux`, `-d macos` |
| Analyze | `cd menu_management && flutter analyze` | Enforced lint rules in `analysis_options.yaml` |
| Code generation | `cd menu_management && dart run build_runner build --delete-conflicting-outputs` | Required after changing any Freezed/json_serializable model |
| Code gen (watch) | `cd menu_management && dart run build_runner watch --delete-conflicting-outputs` | |
| Build release | `cd menu_management && flutter build windows` | |
| Build + copy to Desktop | `cd menu_management && ./build_and_copy.bat` | Windows only; copies portable build to Desktop |
| Run all tests | `cd menu_management && flutter test test/` | 249 tests across 7 files |
| Run single test | `cd menu_management && flutter test test/<file>.dart` | |
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
| `ingredients/` | `IngredientsProvider` | `Ingredient`, `Product` | CRUD for food items; optional store product link per ingredient |
| `recipes/` | `RecipesProvider` | `Recipe`, `Instruction`, `IngredientUsage`, `Quantity`, `Result` | Recipe management with multi-step instructions, inputs/outputs |
| `menu/` | `MenuProvider` | `MultiWeekMenu`, `Menu`, `Meal`, `MealTime`, `Cooking`, `MenuConfiguration` | Multi-week menus (each week = 21 meal slots), generation algorithm |
| `shopping/` | (derived) | `ShoppingIngredient` | Aggregated shopping list from generated menu |
| `theme/` | - | `DynamicTheme`, `ThemeCustom` | Material 3 theming |

### Menu Generation Algorithm

Core logic in `menu_generator.dart`. Fully parameterized: receives `List<Recipe>` and `List<MenuConfiguration>` as parameters, never accesses providers. Multi-phase assignment with priority ordering, yield calculation for leftovers, and time-constraint fitting. See [ADR 0004](adr/0004-menu-generation-algorithm.md) for detailed algorithm documentation.

### Persistence

`persistency.dart` handles file I/O. Fully parameterized: all public methods receive data as parameters (ingredients, recipes, lookup maps), never accessing provider singletons internally. Save is unavailable on iOS/Android due to `FilePicker` limitations. See [ADR 0003](adr/0003-tsr-file-persistence.md) and [ADR 0009](adr/0009-cooking-recipe-id-reference.md).

- **`.tsr` files**: JSON with top-level `"Ingredients"` and `"Recipes"` arrays. On save, `ref_name` fields are injected into `IngredientUsage` entries for human readability.
- **`.tsm` files**: Menus store `recipeId` (UUID) + `ref_name` per meal, not full Recipe objects. On load, each `recipeId` is validated; missing recipes are skipped with a warning.
- Data is **not** automatically saved -- users must manually save via the save button
- On startup, dialogs ask whether to load last session, bundled defaults, or skip (for both recipes and menus)
- Menu configurations are **not** persisted (generated on-demand)

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
- **Provider access is restricted to the UI layer** (widgets, hub.dart, main.dart). Non-UI code (models, generators, persistency helpers) never imports or accesses `Provider.instance`; it receives all required data as parameters.
- Symmetric provider API: both `IngredientsProvider` and `RecipesProvider` expose `get(id)` (with `firstWhereOrNull` + `Debug.logError` + null assertion), a list getter (`.ingredients` / `.recipes`), and `addOrUpdate()` / `remove()` static methods for mutation.
- Provider responsibilities:
  - `IngredientsProvider`: CRUD for ingredients, search history
  - `RecipesProvider`: CRUD for recipes/instructions, filtering by type/nutrition, result/input tracking
  - `MenuProvider`: Holds 21 MenuConfigurations (7 days x 3 meals), triggers menu generation
- Data flow: Widget -> static provider method -> provider updates state -> `notifyListeners()` -> listening widgets rebuild

### Freezed Models
- All data models use Freezed for immutability, `copyWith`, equality, and JSON serialization
- Generated files (`*.freezed.dart`, `*.g.dart`) are excluded from analysis
- Business logic methods are embedded directly on models (e.g., `Recipe.fitsConfiguration()`, `Menu.copyWithUpdatedYields()`)
- **Models never import or call providers.** Cross-entity references use string IDs (e.g., `Cooking.recipeId`, `IngredientUsage.ingredient`), not embedded objects. When a method needs data from another entity, the caller passes it as a list (e.g., `List<Recipe> recipes`).
- Use `const` constructors where possible
- Add empty `const Model._()` constructor to enable custom methods
- Prefer derived getters over storing redundant state
- Key business logic methods (methods needing cross-entity data receive `List<Recipe> recipes`):
  - `Recipe.fitsConfiguration()`: Check if recipe matches meal requirements
  - `Menu.copyWithUpdatedRecipe(recipes:)`: Update a meal's recipe and recalculate yields
  - `Menu.copyWithUpdatedYields(recipes:)`: Calculate yields based on recipe reuse
  - `Menu.allIngredients(recipes:)`: Aggregate all ingredients across meals (respects yields)
  - `MenuConfiguration.canBeCookedAtTheSpot`: Derived from time availability

### Adding or Editing Products (mandatory)

When adding a new Product to an Ingredient or editing an existing one, **always look up the product on the Mercadona API** to fill all fields accurately. Do not guess weights, pack sizes, or shelf life. For countable ingredients (used with `unit: pieces` in recipes), add a separate Product entry with `unit: pieces` alongside the weight-based product.

See [`mercadona-api.md`](mercadona-api.md) for full API documentation, field mapping, and examples of how to determine items per pack for both weight-based and pieces-based products.

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
| [0009](adr/0009-cooking-recipe-id-reference.md) | Cooking stores recipe ID (not full Recipe), parameterized model methods, ref_name for readability |
| [0010](adr/0010-product-entity-store-products.md) | Product entity on Ingredient: optional store product data enabling pack-based shopping list display |
| [0011](adr/0011-grams-per-piece-conversion.md) | Grams-per-piece conversion: optional field bridging pieces and grams for shopping list calculations |
| [0012](adr/0012-max-storage-days.md) | maxStorageDays replaces canBeStored boolean; cross-week leftover tracking |

**Create a new ADR** when making an architectural decision with trade-offs worth preserving. Use the next sequential number.

**Keep ADRs current.** When a change affects an existing decision, update the relevant ADR. If a decision is superseded, mark the old ADR as superseded and reference the new one.

## Gotchas

- After changing any Freezed model, you **must** run `dart run build_runner build --delete-conflicting-outputs` or the app will not compile.
- `*.g.dart` and `*.freezed.dart` are committed to the repo (no build step in CI).
- The `flutter_essentials/` library is a local package inside `lib/`, not a separate pub package.
- Platform target is desktop-first. Mobile platforms have limited save/load support.

## GitHub Issues, PRs, and Other Artifacts

- **Always self-assign PRs** when creating them.
- **Always link PRs to issues** using `Closes #N` in the PR body so issues auto-close on merge.
- **Always add the `waiting-for-human-check` label** when creating GitHub issues, pull requests, or any other reviewable artifact. This signals that no human has verified the content yet -- it is direct AI output. Once a human reviews it, the label is removed. The label communicates state (unreviewed), not origin.

If the repository does not have a `waiting-for-human-check` label, create it first:
```bash
gh label create "waiting-for-human-check" --description "No human has verified this yet -- direct AI output" --color "D93F0B"
```

## Self-Updating Rules

When you discover something during a task that was **non-obvious and would save time in future sessions**, add it to the relevant `CLAUDE.md`. Examples: an undocumented implicit dependency, a silent failure mode, a config quirk that causes hard-to-diagnose bugs.

This also applies when the user tells you to do something **"every time"**, **"always"**, or **"never"**: immediately persist it rather than applying it only for the current session. Always prefer the most specific scope: project-level over global when the rule only applies to this repo.

**Also add** a rule whenever the codebase does something in a way that diverges from what a software developer or an AI would naturally write. If the correct approach here is not the standard/obvious one, a future agent will implement it the wrong way without an explicit rule.

**Do NOT add:**
- Standard patterns discoverable via normal code reading or search
- Things already covered by existing rules
- One-off context unlikely to recur

The bar: if a future agent could reasonably figure it out within a few seconds of exploration, don't add it. Only record knowledge that took a painful detour to uncover, or that diverges from what any competent developer would write by default.

## Deployment

Desktop-only distribution. `build_and_copy.bat` builds a Windows release and copies the portable EXE to the Desktop. No CI/CD pipeline -- builds are manual.
