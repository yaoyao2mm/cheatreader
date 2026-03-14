## ADDED Requirements

### Requirement: Line navigation via wheel and keyboard
The system SHALL support moving the reading position by one visible line in either direction through mouse wheel input and keyboard shortcuts.

#### Scenario: Move forward by line
- **WHEN** the user performs the configured forward line action with the mouse wheel or keyboard
- **THEN** the reader advances by one visible line

#### Scenario: Move backward by line
- **WHEN** the user performs the configured backward line action with the mouse wheel or keyboard
- **THEN** the reader moves backward by one visible line

### Requirement: Page navigation via keyboard
The system SHALL support page-based navigation commands that move the reading position by approximately one visible page relative to the current layout.

#### Scenario: Move forward by page
- **WHEN** the user performs the configured next-page keyboard action
- **THEN** the reader advances by one visible page relative to the current viewport

#### Scenario: Move backward by page
- **WHEN** the user performs the configured previous-page keyboard action
- **THEN** the reader moves backward by one visible page relative to the current viewport

### Requirement: Navigation preserves valid position
The system SHALL clamp navigation so the reading position never moves before the first readable content or beyond the final readable content.

#### Scenario: Attempt to move before start
- **WHEN** the user triggers a backward navigation action while already at the first readable position
- **THEN** the reader remains at the first readable position

#### Scenario: Attempt to move after end
- **WHEN** the user triggers a forward navigation action while already at the final readable position
- **THEN** the reader remains at the final readable position