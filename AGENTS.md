# Menu Management

Flutter desktop app for weekly meal planning. Users create ingredients, build recipes, configure time constraints per meal slot, and generate optimized weekly menus with auto-aggregated shopping lists. All Flutter source code lives under `menu_management/`.

Before implementing any non-trivial feature, delegate to the **pattern-scout** agent.

Before implementing features that touch state management, data models, persistence, menu generation, or app architecture, delegate to the **adr-checker** agent in **consult mode**. After such changes, delegate in **maintain mode**.

After writing or modifying code, delegate to the **validate** agent.

After completing changes that affect documented content, delegate to the **docs-checker** agent.

When the user's request is broad or exploratory, ask whether they'd like to run multi-agent research (`/research-agents`) before proceeding.

## Writing style

The people who read your output may read English as a second language and may be new to the area. Two layers apply. This section is the one home for both: no other file restates them.

**Layer 1 covers every piece of prose you write**: chat replies, PR and issue text, review comments, commit messages, and every document below. It follows Zinsser's four principles, which are simplicity, brevity, clarity, and humanity.

- **Short sentences, one idea each.** Use common words. Avoid idioms, slang, and cultural references.
- **Lead with the answer**, then only the detail that changes what the reader does. Cut filler and hedging. Do not use em dashes.
- **Assume a short attention span.** The reader usually skims to make a quick decision (which PR to review, which issue to pick), with little context and little time; put the single most important thing first, and make each part land even if they stop after the first line.
- **Gloss each jargon term, acronym, or tool/library name on first use** in one short clause, or pick a simpler word.
- **Explain a concept briefly before going deeper.** Do not assume a flow, tool, or pattern is already known.
- **Assume junior-level knowledge of the area.** Name the things you reference (files, commands, terms) instead of assuming the reader can guess.

**Layer 2 adds ASD-STE100 on top, for technical documents only**: `AGENTS.md` and area docs, ADRs, `README.md`, skills, subagents, and code comments. ASD-STE100 (Simplified Technical English) is a controlled-English standard from the aerospace industry. A maintenance manual must carry one reading and one only, and these documents have the same job.

- **Active voice only.** Name the actor: "the hook formats the file", not "the file gets formatted".
- **One meaning per word, and the same word for the same thing every time.** Never swap in a synonym for variety.
- **One instruction per sentence, and start the sentence with the verb.** Write "Run the migration", not "The migration should be run".
- **No `-ing` verb form as a noun or as a sentence opener.** Write "Use the skill to create a branch", not "Creating a branch is done with the skill".
- **About 20 words per sentence at most** (25 in descriptive text).
- **Leave out no word that guards the meaning.** Write "the file that you changed" when "the file you changed" could be misread.

Both layers cover prose only. Neither covers code identifiers or text you quote word for word.

## Documentation Organization

Each kind of knowledge has one home. Write a change in the home that matches it; never duplicate the same content across homes.

| Home | Loaded | Holds |
|------|--------|-------|
| `AGENTS.md` | Every session | The map: architecture facts, conventions, gotchas, and the ADR index. (`CLAUDE.md` is a one-line `@AGENTS.md` shim.) |
| `.claude/skills/<name>/SKILL.md` | On demand, when the task matches | One procedure: how to do X. |
| `adr/NNNN-*.md` | On demand, via adr-checker | One architectural decision and its why. |
| `README.md` | Read by humans | What the app is, how to install/run/deploy, troubleshooting. |

**Rules:**

- ADRs are agent-only: never reference or list them in `README.md`.
- Number ADRs sequentially (`NNNN-kebab-title.md`) and never renumber an existing file. Index each one as a one-line row in the ADR table below, never a summary.
- Do not duplicate content between `README.md` and `AGENTS.md`; reference it instead.
- `CLAUDE.md` is a one-line `@AGENTS.md` shim; edit `AGENTS.md` instead.

## Commands

| Task | Command | Notes |
|------|---------|-------|
| Run app (Windows) | `cd menu_management && flutter run -d windows` | Also supports `-d linux`, `-d macos` |
| Analyze | `cd menu_management && flutter analyze` | Enforced lint rules in `analysis_options.yaml` |
| Code generation | `cd menu_management && dart run build_runner build --delete-conflicting-outputs` | Required after changing any Freezed/json_serializable model |
| Code gen (watch) | `cd menu_management && dart run build_runner watch --delete-conflicting-outputs` | |
| Build release | `cd menu_management && flutter build windows` | |
| Build + copy to Desktop | `./build_and_copy.bat` | Run from repo root; it `cd`s into `menu_management` and runs `build_and_copy.ps1`. Windows only; copies portable build to Desktop |
| Run all tests | `cd menu_management && flutter test test/` | 734 tests across 27 files |
| Run single test | `cd menu_management && flutter test test/<file>.dart` | |
| List devices | `flutter devices` | |
| Format check | `cd menu_management && find lib test -name "*.dart" ! -name "*.freezed.dart" ! -name "*.g.dart" -print0 \| xargs -0 dart format --set-exit-if-changed` | Bash/Git Bash; excludes generated files; fix drift by re-running without `--set-exit-if-changed` |

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
- **`.tsm` files**: Menus store `recipeId` (UUID) + `ref_name` per meal, not full Recipe objects. On load, each `recipeId` is validated; missing recipes are skipped with a warning. A menu may also carry `startDate`, the real date of menu day 0; a file without it keeps the Saturday-first, date-less behavior. Use `menu/menu_dates.dart` to turn a day offset into a date or a label.
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

CI runs the format check, `flutter analyze`, and the full test suite on every PR (see Git Workflow); the repo ruleset "Requirements for merge" blocks merging until the `analyze-and-test` check is green.

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
  - `MenuProvider`: Holds 21 MenuConfigurations (7 days x 3 meals), triggers menu generation; also mirrors the active `MultiWeekMenu` from `MenuPage` (see ADR 0016) so other pages can check recipe references before deleting
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
| [0010](adr/0010-product-entity-store-products.md) | Product entity on Ingredient: store product data, pack-based shopping display, shelf life, expiry warnings |
| [0011](adr/0011-grams-per-piece-conversion.md) | Grams-per-piece conversion: optional field bridging pieces and grams for shopping list calculations |
| [0012](adr/0012-max-storage-days.md) | maxStorageDays replaces canBeStored boolean; cross-week leftover tracking |
| [0013](adr/0013-multiple-sub-meals-per-time-slot.md) | Multiple sub-meals per time slot: SubMeal model, per-person meal assignment |
| [0014](adr/0014-multi-trip-shopping-planner.md) | Multi-trip shopping planner: split-by-trip output via greedy interval point cover |
| [0015](adr/0015-freezable-products-and-freezer-aware-trips.md) | Product.canBeFrozen: freeze-required menu warnings and freezer-aware shopping trips |
| [0016](adr/0016-reference-guarded-deletion.md) | Reference-guarded deletion: warn-confirm-clean-undo cascade; MenuProvider mirrors the active menu |
| [0017](adr/0017-agent-docs-structure.md) | AGENTS.md map + Claude-Code-only skills/subagents/settings |
| [0018](adr/0018-mixed-pack-combination-solver.md) | Mixed-pack combination solver: bounded deterministic search recommending a waste-minimal mix of packs |

**One ADR per pattern, kept alive**: when a pattern changes, update its ADR in place; create a new ADR only for a genuinely new pattern. Do not create successor ADRs or "superseded by" chains; history lives in git. Most changes need no ADR. Conventions: `adr/AGENTS.md`.

**Before implementing** in an area that may carry a decision, delegate to the **adr-checker** agent in consult mode. **After implementing**, delegate in maintain mode only if you introduced a new architectural pattern or changed one an ADR already records.

## Gotchas

- After changing any Freezed model, you **must** run `dart run build_runner build --delete-conflicting-outputs` or the app will not compile.
- `*.g.dart` and `*.freezed.dart` are committed to the repo (no build step in CI).
- The `flutter_essentials/` library is a local package inside `lib/`, not a separate pub package.
- Platform target is desktop-first. Mobile platforms have limited save/load support.

## Git Workflow

- Branch from `main`, PR back to `main`. Whenever you create a branch, use the `create-branch` skill.
- Conventional commits: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`. Whenever you commit, use the `write-commit` skill.
- CI (`.github/workflows/pull-request-checks.yml`) runs format check + `flutter analyze` + tests on every PR; the repo ruleset "Requirements for merge" blocks merging until the `analyze-and-test` check is green.

Whether you are allowed to commit or push at all is set by the user's configuration, not by this file.

## Refactoring Safety

Whenever you rename or refactor a symbol, use the `rename-symbol` skill.

## Debugging

Whenever a fix attempt fails or a bug needs root-causing, use the `debug` skill.

## Writing Prompts for Agents and Rules

Whenever you author or edit an AI-facing file (`AGENTS.md`, skills under `.claude/skills/`, subagents under `.claude/agents/`, prompts for agents you spawn), use the `write-ai-instructions` skill.

## GitHub Issues, PRs, and Other Artifacts

- **Always self-assign PRs** when creating them.
- **Always link PRs to issues** using `Closes #N` in the PR body so issues auto-close on merge.
- **Always add the `waiting-for-human-check` label** when creating GitHub issues, pull requests, or any other reviewable artifact. This signals that no human has verified the content yet -- it is direct AI output. Once a human reviews it, the label is removed. The label communicates state (unreviewed), not origin.

If the repository does not have a `waiting-for-human-check` label, create it first:
```bash
gh label create "waiting-for-human-check" --description "No human has verified this yet -- direct AI output" --color "D93F0B"
```

Whenever you create a GitHub issue, use the `create-issue` skill. Whenever you implement one, use the `implement-issue` skill. Whenever you review a PR, use the `review-pr` skill.

## Self-Updating Rules

Whenever you discover something **extremely hard to find, deeply non-obvious, and time-saving for future sessions**, hit a pattern that **diverges from what an AI would write by default**, the user says **"every time" / "always" / "never"**, or **feedback on your own work reveals a standard you should have followed** (a PR review comment, a user correction), persist it immediately (narrowest scope that fits) instead of applying it only this session. Persist it in these shared, committed files, never in personal memory or the global config, so the whole team gets the lesson. For where to write it, use the `write-ai-instructions` skill.

## Deployment

Desktop-only distribution. `build_and_copy.bat` builds a Windows release and copies the portable EXE to the Desktop. CI runs format check, `flutter analyze`, and tests on every PR (see Git Workflow); builds and distribution remain manual.
