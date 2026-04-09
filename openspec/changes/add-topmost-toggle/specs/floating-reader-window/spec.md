## MODIFIED Requirements

### Requirement: Frameless floating reader window
The system SHALL provide a reader window that can be displayed without standard window borders or status chrome on supported desktop platforms, and it SHALL allow always-on-top behavior to be toggled at runtime rather than forcing it by default.

#### Scenario: Open reader in floating mode with default non-topmost behavior
- **WHEN** the user opens the reader on a platform that supports floating window controls and no saved always-on-top preference exists
- **THEN** the reader window opens without standard chrome and is not forced to remain above other application windows

#### Scenario: Apply saved always-on-top preference at launch
- **WHEN** the user opens the reader and a saved always-on-top preference exists
- **THEN** the reader window applies the saved always-on-top state

#### Scenario: Bring covered reader back to front from taskbar or Dock
- **WHEN** the reader is covered by other windows and the user activates the app from taskbar or Dock
- **THEN** the reader window is shown in the foreground and focused

#### Scenario: Unsupported platform fallback
- **WHEN** the user opens the reader on a platform that does not support frameless always-on-top behavior
- **THEN** the system shows the reader content with the same minimal interface and disables unsupported floating controls without failing to launch
