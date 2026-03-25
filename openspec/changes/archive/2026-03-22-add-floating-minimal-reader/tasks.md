## 1. Project setup and window foundation

- [x] 1.1 Identify and add the Flutter desktop window-management dependency or adapter needed for frameless and always-on-top behavior.
- [x] 1.2 Create the platform window control abstraction that exposes frameless mode, always-on-top, and supported-feature detection.
- [x] 1.3 Wire the app startup flow to initialize the floating reader window on supported desktop platforms and gracefully fall back elsewhere.

## 2. Minimal reader presentation

- [x] 2.1 Build the minimal reader surface without persistent toolbar, status bar, or decorative border.
- [x] 2.2 Implement one-line mode so the reader can collapse to a single visible line and restore the larger reading area without losing position.
- [x] 2.3 Persist core reader presentation preferences such as one-line mode and basic display settings between sessions.

## 3. Navigation controls

- [x] 3.1 Implement semantic reader navigation actions for previous/next line and previous/next page.
- [x] 3.2 Bind mouse wheel input to line navigation with normalization and boundary clamping.
- [x] 3.3 Bind keyboard shortcuts to line and page navigation with platform-appropriate defaults and boundary clamping.

## 4. Quick settings interaction

- [x] 4.1 Implement the right-click context menu anchored to the pointer position on the reading surface.
- [x] 4.2 Add menu actions for one-line mode and supported presentation settings, applying updates immediately.
- [x] 4.3 Add floating-window controls such as always-on-top to the context menu and hide or disable unsupported options by platform.

## 5. Validation

- [x] 5.1 Add automated tests for reader state transitions, navigation clamping, and persisted settings behavior.
- [ ] 5.2 Perform manual validation on supported desktop targets for frameless display, floating behavior, wheel navigation, keyboard paging, and right-click settings.

## 6. Txt import and bookshelf

- [x] 6.1 Add txt drag-and-drop import so dropping a txt file replaces the current content with that file.
- [x] 6.2 Add menu-panel txt import for users who prefer selecting a file instead of dragging it.
- [x] 6.3 Persist lightweight bookshelf records including file path, display name, last-opened time, and last-read position.
- [x] 6.4 Resume reading position by file so reopening the same txt continues from the stored location.
- [x] 6.5 Show a simple bookshelf in the control panel with recent txt files and stale-entry removal.

## 7. Control panel and exit flow

- [x] 7.1 Replace the simple right-click popup menu with a lightweight control panel that can host settings and bookshelf actions.
- [x] 7.2 Add controls for font family, font size, transparency, one-line mode, and always-on-top in the control panel.
- [x] 7.3 Add an explicit exit action in the control panel and a matching keyboard quit path.

## 8. Burn mode

- [x] 8.1 Add a per-file burn-mode toggle that is stored with the bookshelf record for each txt file.
- [x] 8.2 When burn mode is enabled, remove already-read lines from the active reading queue without modifying the source file on disk.
- [x] 8.3 Restore the correct queue state when reopening a file with burn mode enabled.

## 9. Expanded validation

- [x] 9.1 Add automated tests for file-based progress persistence, bookshelf state, and burn-mode queue behavior.
- [ ] 9.2 Manually validate txt drag import, menu-based import, bookshelf resume, burn mode, exit behavior, and updated control-panel settings.