# ADR 0001: Freezed Models with Embedded Business Logic

## Context

Data models need immutability, equality, and JSON serialization. Business logic (e.g., `Recipe.fitsConfiguration()`, `Menu.copyWithUpdatedYields()`) needs to live close to the data it operates on.

## Decision

Use Freezed for all data models. Embed domain-specific business logic as methods directly on the model classes rather than in separate service layers.

## Consequences

- Models are the single source of truth for both data shape and domain rules.
- No separate "service" or "use case" layer needed for domain logic.
- Generated files (`*.freezed.dart`, `*.g.dart`) must be committed and regenerated after model changes.
- **Parameterized methods for cross-model lookups**: When a model method needs data from another entity (e.g., resolving a recipe ID to a full Recipe), the required data is passed as a list parameter (e.g., `List<Recipe> recipes`). This keeps models pure and testable without introducing provider dependencies or a service layer. See ADR 0009 for the motivating change.
