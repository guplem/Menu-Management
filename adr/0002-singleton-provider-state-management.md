# ADR 0002: Singleton Provider State Management

## Context

The app needs a state management approach for three independent feature domains (ingredients, recipes, menu).

## Decision

Use the Provider package with singleton `ChangeNotifier` providers. Each provider exposes static mutation methods (`addOrUpdate`, `remove`) and is wired up via `MultiProvider` in `main.dart`.

## Consequences

- Simple, predictable state flow with no extra dependencies.
- Providers are singletons, so state is global and persists for the app lifetime.
- `listenableOf()` helper enables fine-grained widget rebuilds for individual items.
