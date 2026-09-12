# ADR 0003: File-Based Persistence

## Context

The app needs to save and load user data (ingredients, recipes) and generated menus. It targets desktop platforms primarily.

## Decision

Persist data as JSON-based files via `FilePicker`, using two distinct formats:

- **`.tsr` files** -- Store ingredients and recipes. JSON structure has top-level `"Ingredients"` and `"Recipes"` arrays. Saved/loaded through `Persistency.saveData()` / `Persistency.loadData()`.

- **`.tsm` files** -- Store generated menus (single-week or multi-week). Each meal's `Cooking` object stores a `recipeId` (UUID string) referencing a recipe in the recipe book, plus a `ref_name` field for human readability (ignored by the app on load). Saved through `Persistency.saveMenu()`, loaded through `Persistency.loadMultiWeekMenu()`. The loader detects whether the JSON contains a `"weeks"` key (multi-week format) or just `"meals"` (old single-week format) and handles both. On load, each `recipeId` is validated against the loaded recipe book; meals referencing missing recipes have their cooking set to null with a warning logged.

- **Exports that are not JSON** (for example the menu PDF) -- `Persistency.saveBytes()` asks the user where to save through the same `FilePicker` save dialog, then writes raw bytes with `saveBytesToPath()`. `saveBytesToPath()` writes the picked path as it came back and adds no extension: the save dialog asks about the name that the user typed, so a changed name could overwrite a file that the user never saw. `Persistency.supportsFileSaving()` reports whether the device has a save dialog at all; `FileExportOption` asks it before it builds any byte and warns the user instead of failing silently on iOS/Android. The `.tsm` and `.tsr` saves do not ask it yet, so they still fail without a word on mobile. An export writes no `last_session.json` entry, because the app has nothing that reads such a file back. `Persistency.defaultMenuFileName()` takes an `extension` parameter so a `.tsm` save and a PDF export of the same menu propose the same file name, differing only in extension.

On startup, sequential dialogs ask the user whether to load recipes (last saved, bundled defaults, or skip) and then whether to load a menu (same options). The app tracks the last saved/loaded `.tsr` and `.tsm` paths in `%APPDATA%/MenuManagement/last_session.json`.

## Consequences

- No database dependency; fully portable data files.
- Save/load is unavailable on iOS/Android due to `FilePicker` limitations.
- Users manage their own file storage locations.
- Menu configurations (the 21-slot grid in `MenuProvider`) are not persisted. They reset to defaults on each app launch.
- The release-mode startup load requires user interaction (file picker), so there is no silent background restore.
- A byte-based export (the PDF) reuses the save dialog but skips the last-session bookkeeping, so it cannot silently grow into a format the app tries to load back; a future loadable binary format needs its own decision.
