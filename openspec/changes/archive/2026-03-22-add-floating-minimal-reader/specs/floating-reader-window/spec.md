## ADDED Requirements

### Requirement: Frameless floating reader window
The system SHALL provide a reader window that can be displayed without standard window borders or status chrome on supported desktop platforms, and it MUST support staying above other application windows when floating mode is enabled.

#### Scenario: Open reader in floating mode
- **WHEN** the user opens the reader on a platform that supports floating window controls
- **THEN** the reader window opens without standard chrome and is configured to remain above normal application windows

#### Scenario: Unsupported platform fallback
- **WHEN** the user opens the reader on a platform that does not support frameless always-on-top behavior
- **THEN** the system shows the reader content with the same minimal interface and disables unsupported floating controls without failing to launch

### Requirement: One-line minimal presentation
The system SHALL allow the reader to switch into a minimal presentation mode that shows a single readable line of content while preserving the current reading position.

#### Scenario: Enable one-line mode
- **WHEN** the user enables one-line mode
- **THEN** the reader resizes or reflows to display a single line of content and keeps the current reading position anchored

#### Scenario: Exit one-line mode
- **WHEN** the user disables one-line mode
- **THEN** the reader restores a larger reading area without losing the current reading position

### Requirement: Minimal visual chrome
The system SHALL keep the reading surface free of persistent toolbars, status bars, and decorative borders during normal reading.

#### Scenario: Reader idle state
- **WHEN** the reader is displayed during normal use
- **THEN** no persistent toolbar, status bar, or decorative border is shown around the reading content