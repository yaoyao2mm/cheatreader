## Why

The project needs an extremely minimal reader that can stay visible during work without looking like a traditional app window. A tiny, frameless, always-floating reading surface with fast input controls makes the product usable in short attention windows across supported Flutter platforms.

## What Changes

- Add a frameless floating reader window that can shrink down to a single visible line of text.
- Add reading controls for line-by-line movement and page movement via mouse wheel and keyboard shortcuts.
- Replace the simple right-click menu with a lightweight menu page that exposes reader controls, txt import, a simple bookshelf, and an explicit exit action.
- Define behavior for hiding standard chrome, preserving top-level floating behavior, and keeping the interface visually minimal.
- Establish a Flutter-friendly cross-platform capability set, with desktop behavior prioritized for always-on-top floating usage.
- Support dragging txt files into the reader and importing txt files from the menu page.
- Persist reading position by file so reopening the same txt resumes from the last position.
- Add a simple bookshelf of recently imported txt files with quick resume behavior.
- Add an optional per-file "阅后即焚" mode that removes already-read lines from the active reading queue without modifying the source txt file.
- Add an explicit exit action so the floating reader can always be closed intentionally.

## Capabilities

### New Capabilities
- `floating-reader-window`: A minimal floating reading surface that can stay above other windows, remove standard chrome, and collapse to a one-line presentation.
- `reader-navigation-controls`: Input handling for mouse wheel and keyboard navigation across lines and pages.
- `reader-control-panel`: A lightweight right-click menu page for import, bookshelf access, presentation settings, and exit actions.
- `txt-reading-library`: Txt import, drag-and-drop ingestion, simple bookshelf entries, and per-file reading-position resume.
- `reader-burn-mode`: A per-file consumption mode that hides already-read lines from the active reading queue without editing the source file.

### Modified Capabilities
- None.

## Impact

- Affects Flutter app shell, window management, reader presentation layer, input handling, file import flow, and persisted bookshelf state.
- Likely introduces desktop window-management plugins or platform channel integrations for frameless and always-on-top behavior.
- Requires new UX definitions for the control panel, bookshelf state, file resume behavior, and burn-mode behavior.