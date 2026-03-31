# ADR 0001: Freezed Models with Embedded Business Logic

## Context

Data models need immutability, equality, and JSON serialization. Business logic (e.g., `Recipe.fitsConfiguration()`, `Menu.copyWithUpdatedYields()`) needs to live close to the data it operates on.

## Decision

Use Freezed for all data models. Embed domain-specific business logic as methods directly on the model classes rather than in separate service layers.

## Consequences

- Models are the single source of truth for both data shape and domain rules.
- No separate "service" or "use case" layer needed for domain logic.
- Generated files (`*.freezed.dart`, `*.g.dart`) must be committed and regenerated after model changes.
