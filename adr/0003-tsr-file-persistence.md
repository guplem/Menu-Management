# ADR 0003: File-Based Persistence

## Context

The app needs to save and load user data (ingredients, recipes) and generated menus. It targets desktop platforms primarily.

## Decision

Persist data as JSON-based files via `FilePicker`, using two distinct formats:

- **`.tsr` files** -- Store ingredients and recipes. JSON structure has top-level `"Ingredients"` and `"Recipes"` arrays. Saved/loaded through `Persistency.saveData()` / `Persistency.loadData()`.

- **`.tsm` files** -- Store generated menus (single-week or multi-week). Saved through `Persistency.saveMenu()`, loaded through `Persistency.loadMultiWeekMenu()`. The loader is backward-compatible: if the JSON contains a `"weeks"` key it is parsed as `MultiWeekMenu`; otherwise it is treated as a single `Menu` and wrapped in a one-week `MultiWeekMenu`.

On release builds, `main.dart` calls `Persistency.loadData()` at startup, which opens a file picker dialog prompting the user to select a `.tsr` file. This does not happen in debug mode. Menu files (`.tsm`) are never auto-loaded.

## Consequences

- No database dependency; fully portable data files.
- Save/load is unavailable on iOS/Android due to `FilePicker` limitations.
- Users manage their own file storage locations.
- Menu configurations (the 21-slot grid in `MenuProvider`) are not persisted. They reset to defaults on each app launch.
- The release-mode startup load requires user interaction (file picker), so there is no silent background restore.
