# reader-control-panel Specification

## Purpose
TBD - created by archiving change add-floating-minimal-reader. Update Purpose after archive.
## Requirements
### Requirement: Right-click control panel
The system SHALL open a lightweight control panel when the user right-clicks on the reading surface.

#### Scenario: Open control panel
- **WHEN** the user right-clicks within the reader window
- **THEN** the system displays a control panel that provides reader actions without adding persistent chrome to the reading surface

### Requirement: In-session presentation controls
The system SHALL allow the user to change core reader presentation settings from the control panel, including toggling one-line mode and adjusting basic presentation options defined for the release.

#### Scenario: Toggle one-line mode from panel
- **WHEN** the user selects the one-line mode option from the control panel
- **THEN** the reader immediately toggles one-line mode

#### Scenario: Update presentation option from panel
- **WHEN** the user changes a supported presentation option from the control panel
- **THEN** the reader updates the presentation without requiring an app restart

### Requirement: Floating behavior controls
The system SHALL expose supported floating-window controls through the control panel, including always-on-top when the current platform allows it.

#### Scenario: Toggle always-on-top
- **WHEN** the user selects the always-on-top option on a platform that supports it
- **THEN** the reader updates the window behavior immediately to match the selected state

#### Scenario: Unsupported floating control
- **WHEN** the user opens the control panel on a platform that does not support a floating-window control
- **THEN** the unsupported control is hidden or disabled

### Requirement: Import and bookshelf actions
The control panel SHALL provide entry points for importing txt files and reopening files from the simple bookshelf.

#### Scenario: Import txt from panel
- **WHEN** the user selects the import action from the control panel
- **THEN** the system prompts for a txt file and loads it into the reader

#### Scenario: Open a bookshelf entry from panel
- **WHEN** the user selects a previously imported txt file from the control panel bookshelf
- **THEN** the system opens that file and resumes from its stored reading position when available

### Requirement: Explicit exit action
The control panel SHALL provide an explicit exit action for closing the reader application.

#### Scenario: Exit from panel
- **WHEN** the user selects the exit action from the control panel
- **THEN** the application closes cleanly

