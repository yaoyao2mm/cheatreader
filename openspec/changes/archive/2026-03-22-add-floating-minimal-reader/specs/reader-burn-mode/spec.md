## ADDED Requirements

### Requirement: Per-file burn-mode setting
The system SHALL allow burn mode to be enabled or disabled independently for each imported txt file.

#### Scenario: Enable burn mode for one file
- **WHEN** the user enables burn mode while reading a specific txt file
- **THEN** the system stores burn mode as enabled for that file without changing burn mode for other files

### Requirement: Burn mode consumes read lines in-app
When burn mode is enabled, the system SHALL remove already-read lines from the active reading queue without modifying the source txt file on disk.

#### Scenario: Advance with burn mode enabled
- **WHEN** the user moves forward while burn mode is enabled for the current file
- **THEN** the reader no longer shows lines already consumed in that reading queue

#### Scenario: Source file remains unchanged
- **WHEN** the user reads a file with burn mode enabled
- **THEN** the source txt file on disk is not edited or truncated by the reader

### Requirement: Burn-mode resume
The system SHALL restore burn-mode progress for a file when that file is reopened.

#### Scenario: Reopen file with saved burn-mode progress
- **WHEN** the user reopens a txt file that has saved burn-mode state and progress
- **THEN** the reader restores the remaining unread queue for that file