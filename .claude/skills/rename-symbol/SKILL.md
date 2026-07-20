---
name: rename-symbol
description: Rename or refactor a symbol safely by searching every naming-case variant across code, tests, docs, configs, and JSON. Use when renaming any identifier so no reference is missed.
---

# Rename a symbol safely

When you rename or refactor any symbol, search **all** naming variants (camelCase, PascalCase, snake_case, kebab-case, UPPER_CASE) across the whole project (code, tests, docs, configs, and JSON), not just the obvious code references. A missed variant in a config key or a data file is the usual cause of a rename that compiles fine but breaks at runtime.

Extra traps in this repo:

- **Generated Freezed / json_serializable files** (`*.freezed.dart`, `*.g.dart`) contain the old name. Never edit them by hand: re-run `cd menu_management && dart run build_runner build --delete-conflicting-outputs`, then confirm no stale references remain.
- **Serialized JSON keys are a storage schema.** `.tsr` files use top-level `"Ingredients"` / `"Recipes"` keys and inject `ref_name`; `.tsm` files store `recipeId` + `ref_name` per meal. Renaming the Dart field is safe, but changing the persisted `@JsonKey` string breaks every existing saved file and needs an explicit migration, not just a rename.
- **Enum values serialize by name.** Enums are PascalCase types with lowercase values; json_serializable writes the value's name into the file. Renaming an enum value changes the stored string, so old saved files stop loading unless you migrate them.
- **Provider singletons and their static methods** (`get`, `addOrUpdate`, `remove`, list getters) are called from the UI layer across features; rename them everywhere in one pass.
