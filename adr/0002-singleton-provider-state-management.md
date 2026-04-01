# ADR 0002: Singleton Provider State Management

## Context

The app needs a state management approach for three independent feature domains (ingredients, recipes, menu).

## Decision

Use the Provider package with singleton `ChangeNotifier` providers. Each provider is wired up via `MultiProvider` in `main.dart`.

Two patterns exist depending on whether the provider manages a dynamic collection or a fixed grid:

- **Dynamic-collection providers** (`IngredientsProvider`, `RecipesProvider`): Items are identified by a string ID. Expose static `addOrUpdate` and `remove` methods. `listenableOf(context, id)` enables fine-grained widget rebuilds for individual items.

- **Fixed-grid provider** (`MenuProvider`): Manages a fixed set of 21 `MenuConfiguration` slots (7 days x 3 meals). Configurations are never added or removed -- they are always present. Exposes a static `update` method that replaces a configuration matched by its composite key `(WeekDay, MealType)`. `listenableOf(context, {weekDay, mealType})` uses named parameters instead of a single ID.

## Consequences

- Simple, predictable state flow with no extra dependencies.
- Providers are singletons, so state is global and persists for the app lifetime.
- The two patterns reflect different domain semantics: CRUD for open-ended collections vs. in-place mutation for a fixed grid.
