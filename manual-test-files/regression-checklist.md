# Floating Reader Regression Checklist

Use this checklist before release builds that change desktop window behavior.

## Always-on-top default and toggle

- [ ] Launch on a clean profile (no `reader.alwaysOnTop` preference saved) and verify the control panel `Always on top` switch starts OFF.
- [ ] Enable `Always on top` in the control panel and verify the reader immediately stays above other app windows.
- [ ] Disable `Always on top` and verify the reader can be covered by other app windows immediately.
- [ ] Relaunch after explicitly enabling `Always on top` and verify the enabled state is preserved.
- [ ] Relaunch after explicitly disabling `Always on top` and verify the disabled state is preserved.

## Taskbar or Dock foreground recovery

- [ ] With `Always on top` OFF, cover the reader with another app window.
- [ ] Click the CheatReader icon from taskbar (Windows/Linux) or Dock (macOS).
- [ ] Verify the reader returns to foreground and receives keyboard focus.

## Safety checks for existing flows

- [ ] Open and close the control panel repeatedly and verify window size/position restoration still works.
- [ ] Trigger boss key hide/restore and verify foreground recovery logic does not break the hide/restore cycle.
- [ ] On unsupported floating-control environments, verify the always-on-top control remains hidden or disabled.
