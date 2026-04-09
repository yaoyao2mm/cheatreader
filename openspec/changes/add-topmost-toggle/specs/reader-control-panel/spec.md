## MODIFIED Requirements

### Requirement: Floating behavior controls
The system SHALL expose supported floating-window controls through the control panel, including an always-on-top toggle that defaults to off for users without a saved preference.

#### Scenario: Default always-on-top state in control panel
- **WHEN** the user opens the control panel on a platform that supports floating-window controls and no saved always-on-top preference exists
- **THEN** the always-on-top toggle is shown in the off state

#### Scenario: Toggle always-on-top on
- **WHEN** the user enables the always-on-top option on a platform that supports it
- **THEN** the reader updates the window behavior immediately to remain above normal application windows

#### Scenario: Toggle always-on-top off
- **WHEN** the user disables the always-on-top option on a platform that supports it
- **THEN** the reader updates the window behavior immediately so it can be covered by other windows

#### Scenario: Unsupported floating control
- **WHEN** the user opens the control panel on a platform that does not support a floating-window control
- **THEN** the unsupported control is hidden or disabled
