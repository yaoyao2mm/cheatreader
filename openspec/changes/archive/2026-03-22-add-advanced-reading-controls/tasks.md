## 1. Settings foundation

- [x] 1.1 Extend reader settings and persistence to include line spacing, reading width, shortcut bindings, and boss-key configuration defaults.
- [x] 1.2 Add controller-level actions and state updates for the new reading controls while preserving existing reading progress behavior.
- [x] 1.3 Add validation rules for supported shortcut assignments and conflict detection.

## 2. Reader layout controls

- [x] 2.1 Apply configurable line spacing to reader text rendering and visible-line-capacity calculations.
- [x] 2.2 Apply configurable reading width to the reader text column without replacing existing outer window sizing behavior.
- [x] 2.3 Add automated tests covering persisted line spacing and reading width behavior.

## 3. Shortcut customization

- [x] 3.1 Refactor keyboard handling so configurable shortcut bindings trigger semantic reader actions.
- [x] 3.2 Add control-panel UI for viewing and changing supported shortcut bindings.
- [x] 3.3 Add automated tests for custom shortcut activation and shortcut-conflict rejection.

## 4. Boss key behavior

- [x] 4.1 Extend the platform window adapter with non-destructive hide/show behavior needed for the boss key.
- [x] 4.2 Wire the configured boss-key shortcut to hide and restore the reader window without quitting the app.
- [x] 4.3 Add tests or adapter-level verification for boss-key state preservation and graceful fallback on unsupported platforms.

## 5. Control panel and validation

- [x] 5.1 Add control-panel controls for line spacing, reading width, and boss-key configuration while keeping the panel compact.
- [x] 5.2 Update user-facing descriptions and documentation for the new reading controls.
- [ ] 5.3 Manually validate the new controls on supported desktop targets, including shortcut remapping and boss-key hide/restore behavior.
