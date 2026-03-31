# ADR 0003: .tsr File-Based Persistence

## Context

The app needs to save and load user data (ingredients, recipes, menu configurations). It targets desktop platforms primarily.

## Decision

Persist all data as `.tsr` files (JSON-based) via `FilePicker`. On release builds, auto-load the last saved file on startup.

## Consequences

- No database dependency; fully portable data files.
- Save/load is unavailable on iOS/Android due to `FilePicker` limitations.
- Users manage their own file storage locations.
