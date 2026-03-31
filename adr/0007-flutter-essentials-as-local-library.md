# ADR 0007: flutter_essentials as a Local Library

## Context

The project needs reusable utilities (extensions on core Dart/Flutter types, custom card widgets, button variants, debug helpers, provider utilities) that are not specific to the menu management domain. These could live as a separate pub package, a separate local package with its own `pubspec.yaml`, or as a directory inside `lib/`.

## Decision

Keep `flutter_essentials/` as a directory inside `lib/` with a barrel file (`library.dart`) that re-exports everything. It is not a separate pub package or a standalone local package.

### Why not a separate pub package
- The utilities are general-purpose but tailored to this project's needs (e.g., specific card styles matching the app's Material 3 theme, provider helpers for the singleton pattern used here).
- Publishing and versioning a separate package adds maintenance overhead with no benefit for a single-consumer project.
- No other projects depend on it.

### Why not a separate local package (with its own pubspec.yaml)
- A local package would require its own dependency declarations, test setup, and build configuration.
- Since it lives inside the same app and shares the same dependencies, a directory is simpler and avoids dependency version synchronization issues.

### How it works
- `library.dart` is the single import point: `import "package:menu_management/flutter_essentials/library.dart"` gives access to all utilities.
- Contents are organized into `utils/` (extensions, helpers), `utils/extensions/` (type extensions), and `widgets/` (reusable UI components).
- Uses package imports (`package:menu_management/...`) like the rest of the codebase, not relative imports.

## Consequences

- Simple to use: one import gets everything.
- No separate build or publish step.
- If the library grows large enough to warrant reuse across projects, it can be extracted into a standalone package later. The barrel file pattern makes this migration straightforward.
- New utilities should be added here (not scattered across feature directories) and exported from `library.dart`.
