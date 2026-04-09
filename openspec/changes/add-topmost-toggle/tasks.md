## 1. Settings default and persistence

- [x] 1.1 Change `ReaderSettings.defaults.alwaysOnTop` to `false` so new users start with non-topmost behavior.
- [x] 1.2 Keep preference loading logic backward compatible so existing saved always-on-top values are preserved.
- [x] 1.3 Add or update settings/preference tests to verify default-off fallback only applies when no saved key exists.

## 2. Foreground recovery from taskbar or Dock

- [x] 2.1 Add a desktop window-controller action that explicitly brings the reader window to foreground (`show` + `focus`) without forcing always-on-top on.
- [x] 2.2 Wire window activation/restore listener handling in the reader surface to invoke foreground recovery when users reactivate the app from taskbar or Dock.
- [x] 2.3 Ensure foreground recovery does not break boss-key hide/restore or control-panel transitions.

## 3. Control panel floating toggle behavior

- [x] 3.1 Ensure the control panel always-on-top toggle reflects the loaded setting state (off by default for users without saved preference).
- [x] 3.2 Verify toggling on/off updates native window z-order immediately on supported desktop platforms.
- [x] 3.3 Keep unsupported-platform behavior unchanged (toggle hidden or disabled).

## 4. Validation

- [x] 4.1 Add or adjust automated tests for always-on-top state transitions and window-controller sync behavior.
- [ ] 4.2 Manually validate macOS, Windows, and Linux flows: default off, manual toggle on/off, and taskbar/Dock click restoring the reader to foreground.
- [x] 4.3 Update regression checklist for floating reader behavior to include the new default and reactivation expectations.
