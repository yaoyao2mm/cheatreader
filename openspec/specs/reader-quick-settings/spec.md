# reader-quick-settings Specification

## Purpose
TBD - created by archiving change add-floating-minimal-reader. Update Purpose after archive.
## Requirements
### Requirement: Right-click settings menu
The system SHALL open a context menu with reader settings when the user right-clicks on the reading surface.

#### Scenario: Open settings menu
- **WHEN** the user right-clicks within the reader window
- **THEN** the system displays a context menu anchored to the pointer location

### Requirement: In-session presentation controls
The system SHALL allow the user to change core reader presentation settings from the context menu, including toggling one-line mode and adjusting basic presentation options defined for the release.

#### Scenario: Toggle one-line mode from menu
- **WHEN** the user selects the one-line mode option from the context menu
- **THEN** the reader immediately toggles one-line mode

#### Scenario: Update presentation option from menu
- **WHEN** the user changes a supported presentation option from the context menu
- **THEN** the reader updates the presentation without requiring an app restart

### Requirement: Floating behavior controls
The system SHALL expose supported floating-window controls through the context menu, including always-on-top when the current platform allows it.

#### Scenario: Toggle always-on-top
- **WHEN** the user selects the always-on-top option on a platform that supports it
- **THEN** the reader updates the window behavior immediately to match the selected state

#### Scenario: Unsupported floating control
- **WHEN** the user opens the context menu on a platform that does not support a floating-window control
- **THEN** the unsupported control is hidden or disabled

