## Why

CheatReader now has a stable floating reading core, but the reading controls are still too sparse for long-term daily use. Users need a few higher-leverage controls, especially line spacing, reading width, customizable shortcuts, and a fast “boss key” hide/show action, to make the reader adaptable without losing its low-distraction character.

## What Changes

- Add adjustable line spacing so readers can open up dense text without changing the minimal reading surface.
- Add reading width controls that let users narrow or widen the text block independently of raw window size.
- Add customizable keyboard shortcuts for core reader actions instead of relying on a fixed small set of defaults.
- Add a “boss key” action that can instantly hide and restore the reader window without quitting the app.
- Extend settings persistence, control-panel UI, and user-facing descriptions so the new reading controls are configurable and restorable across sessions.
- Add automated coverage for the new settings state, shortcut handling, and boss-key behavior where feasible.

## Capabilities

### New Capabilities
- `advanced-reading-controls`: Line spacing, reading width, configurable shortcuts, and boss-key behavior for the floating reader experience.

### Modified Capabilities
- None.

## Impact

- Affects reader settings/state, keyboard input handling, reader presentation/layout, platform window control integration, control-panel UI, and persisted preferences.
- May require small extensions to the platform window adapter to support non-destructive hide/show behavior for the boss key.
- Expands test coverage for settings persistence and keyboard interaction, and may require new UX copy for configurable shortcuts and boss-key affordances.
