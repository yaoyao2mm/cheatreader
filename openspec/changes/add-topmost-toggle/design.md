## Context

The reader currently defaults to `alwaysOnTop = true` when no saved preference exists. This causes the reader to stay above working windows until users manually disable it. The control panel already exposes an always-on-top toggle, but the default behavior does not match users who want the reader to be temporarily coverable during normal work. We also need deterministic foreground recovery: when the reader is covered, clicking the app icon in taskbar/Dock should bring it back to the front.

## Goals / Non-Goals

**Goals:**
- Default always-on-top to OFF for users without an existing saved preference.
- Keep always-on-top as an explicit, user-controlled toggle in the reader menu/control panel.
- Ensure taskbar/Dock activation brings the reader window to foreground and focused state when it has been covered.
- Preserve existing saved user preference values without destructive migration.

**Non-Goals:**
- Adding a system tray workflow or background daemon behavior.
- Changing non-desktop platforms to emulate desktop floating behavior.
- Redesigning the control panel UI structure beyond this toggle behavior.

## Decisions

### 1. Change only the default fallback value, not persisted user values
Set `ReaderSettings.defaults.alwaysOnTop` to `false`, and continue using preference storage as source of truth when the key already exists.

Rationale: Existing users who explicitly enabled/disabled this setting should keep their current behavior, while new installs get the requested default.

Alternatives considered:
- Force-reset all users to OFF via migration. Rejected because it overrides intentional existing preferences.
- Keep default ON and rely on onboarding copy. Rejected because it does not solve the core UX complaint.

### 2. Keep immediate runtime sync from setting state to native window behavior
Continue using the existing settings-driven sync path so toggling always-on-top updates native window z-order immediately.

Rationale: The app already centralizes presentation sync in the desktop window controller; extending that flow is lower-risk than introducing parallel window state.

Alternatives considered:
- Add a separate transient z-order state outside reader settings. Rejected due added complexity and state divergence risk.

### 3. Add explicit foreground recovery on desktop activation events
Handle desktop window activation/restore events and call foreground actions (`show` + `focus`) to guarantee the reader returns to front when users click taskbar/Dock icon.

Rationale: Relying purely on OS defaults can vary across platforms/window styles (frameless windows especially). Explicit recovery creates a consistent contract.

Alternatives considered:
- Assume OS taskbar/Dock activation is always sufficient. Rejected due cross-platform inconsistency risk.

### 4. Keep unsupported floating controls disabled
Retain capability checks for platforms that do not support floating controls.

Rationale: Prevents broken toggles and keeps behavior predictable.

## Risks / Trade-offs

- [Activation handlers can cause redundant focus calls] -> Mitigation: guard against no-op or repeated calls where possible.
- [Platform-specific event timing differences] -> Mitigation: validate on macOS, Windows, Linux manually in addition to unit tests.
- [Changing default may surprise users who expected legacy behavior] -> Mitigation: keep toggle visible and clearly labeled in the control panel.

## Migration Plan

1. Update default settings fallback for always-on-top to OFF.
2. Keep preference read/write behavior unchanged so existing saved values remain intact.
3. Add/adjust desktop activation handling to ensure window comes to foreground on taskbar/Dock click.
4. Validate via targeted manual checks across supported desktop platforms.

Rollback strategy:
- Revert default fallback to ON and disable explicit activation handling if regressions appear.

## Open Questions

- Should foreground recovery also run on every generic focus event, or only restore/activate pathways from taskbar/Dock?
- Do we want a one-time release note in-app to explain the new default behavior?
