# advanced-reading-controls Specification

## Purpose
TBD - created by archiving change add-advanced-reading-controls. Update Purpose after archive.
## Requirements
### Requirement: Reader line spacing can be adjusted
The system SHALL allow users to change reader line spacing and SHALL apply the selected spacing consistently to reading layout and navigation calculations.

#### Scenario: Line spacing changes visible layout
- **WHEN** a user changes the line-spacing setting
- **THEN** the reader updates text spacing without losing the current reading position

#### Scenario: Line spacing affects page capacity consistently
- **WHEN** a user increases or decreases line spacing
- **THEN** page and visible-line calculations use the same spacing value that is used for rendering

### Requirement: Reader width can be adjusted independently of raw window resizing
The system SHALL allow users to change the effective reading width of the text block without requiring manual window resizing for every adjustment.

#### Scenario: Reading width narrows the text column
- **WHEN** a user selects a narrower reading width
- **THEN** the reader renders text inside a narrower readable area while preserving the surrounding reader surface behavior

#### Scenario: Reading width persists across sessions
- **WHEN** a user relaunches the app after changing reading width
- **THEN** the reader restores the previously selected reading width setting

### Requirement: Core reader shortcuts can be customized
The system SHALL allow users to customize supported keyboard shortcuts for core reader actions and SHALL persist those bindings across sessions.

#### Scenario: Custom shortcut triggers a reader action
- **WHEN** a user assigns a supported shortcut to a reader action
- **THEN** pressing that shortcut while the app is focused triggers the mapped action

#### Scenario: Shortcut settings persist
- **WHEN** a user restarts the app after changing shortcut bindings
- **THEN** the custom bindings remain active

### Requirement: The app validates shortcut conflicts
The system SHALL prevent unsupported or conflicting shortcut assignments from silently replacing existing behavior.

#### Scenario: Reject conflicting shortcut binding
- **WHEN** a user attempts to assign the same shortcut to two incompatible reader actions
- **THEN** the app rejects the conflicting assignment or requires an explicit reassignment flow instead of leaving bindings ambiguous

### Requirement: The boss key can hide and restore the reader without quitting
The system SHALL provide a boss-key action that hides the reader window and allows it to be restored later without losing reading state.

#### Scenario: Boss key hides the reader
- **WHEN** the user triggers the configured boss-key shortcut
- **THEN** the reader window becomes hidden without closing the app or resetting reading progress

#### Scenario: Boss key restores the reader
- **WHEN** the user triggers the restore path for the boss key after the reader has been hidden
- **THEN** the reader window becomes visible again with the same reading state as before hiding

### Requirement: Advanced reading controls are exposed in the control panel
The system SHALL expose line spacing, reading width, shortcut customization, and boss-key configuration in the app’s existing control surface.

#### Scenario: Control panel shows advanced controls
- **WHEN** the user opens the control panel
- **THEN** the panel includes controls for line spacing, reading width, shortcut configuration, and boss-key behavior

