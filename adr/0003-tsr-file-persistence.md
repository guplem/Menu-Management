# ADR 0003: File-Based Persistence

## Context

The app needs to save and load user data (ingredients, recipes) and generated menus. It targets desktop platforms primarily.

## Decision

Persist data as JSON-based files via `FilePicker`, using two distinct formats:

- **`.tsr` files** -- Store ingredients and recipes. JSON structure has top-level `"Ingredients"` and `"Recipes"` arrays. Saved/loaded through `Persistency.saveData()` / `Persistency.loadData()`.

- **`.tsm` files** -- Store generated menus (single-week or multi-week). Each meal's `Cooking` object stores a `recipeId` (UUID string) referencing a recipe in the recipe book, plus a `ref_name` field for human readability (ignored by the app on load). Saved through `Persistency.saveMenu()`, loaded through `Persistency.loadMultiWeekMenu()`. The loader detects whether the JSON contains a `"weeks"` key (multi-week format) or just `"meals"` (old single-week format) and handles both. On load, each `recipeId` is validated against the loaded recipe book; meals referencing missing recipes have their cooking set to null with a warning logged.

On startup, sequential dialogs ask the user whether to load recipes (last saved, bundled defaults, or skip) and then whether to load a menu (same options). The app tracks the last saved/loaded `.tsr` and `.tsm` paths in `%APPDATA%/MenuManagement/last_session.json`.

## Consequences

- No database dependency; fully portable data files.
- Save/load is unavailable on iOS/Android due to `FilePicker` limitations.
- Users manage their own file storage locations.
- Menu configurations (the 21-slot grid in `MenuProvider`) are not persisted. They reset to defaults on each app launch.
- The release-mode startup load requires user interaction (file picker), so there is no silent background restore.
