# txt-reading-library Specification

## Purpose
TBD - created by archiving change add-floating-minimal-reader. Update Purpose after archive.
## Requirements
### Requirement: Txt drag-and-drop import
The system SHALL allow the user to drag a `.txt` file into the reader window to load that file as the current reading source.

#### Scenario: Drop txt into reader
- **WHEN** the user drops a `.txt` file onto the reader window
- **THEN** the system loads that file into the reader as the current reading source

#### Scenario: Reject unsupported file type
- **WHEN** the user drops a file that is not a supported `.txt` source
- **THEN** the system rejects the file gracefully and keeps the current reading source unchanged

### Requirement: Txt import from control panel
The system SHALL allow the user to import a `.txt` file from the control panel.

#### Scenario: Import txt from picker
- **WHEN** the user selects the import action in the control panel and chooses a valid `.txt` file
- **THEN** the system loads that file into the reader as the current reading source

### Requirement: Per-file reading resume
The system SHALL store reading progress by file so reopening the same txt resumes from the last saved position.

#### Scenario: Resume a previously opened file
- **WHEN** the user opens a txt file that already has saved progress
- **THEN** the reader starts from that file's saved reading position

#### Scenario: Open a new file
- **WHEN** the user opens a txt file that has no saved progress
- **THEN** the reader starts from the beginning of that file

### Requirement: Simple bookshelf
The system SHALL maintain a simple bookshelf of imported txt files for quick reopening.

#### Scenario: Show recent files
- **WHEN** the user opens the control panel after importing one or more txt files
- **THEN** the control panel shows recent bookshelf entries with enough information to identify and reopen them

#### Scenario: Remove stale bookshelf entry
- **WHEN** a bookshelf entry points to a file that is no longer available and the user removes it
- **THEN** the system deletes the stale entry from the bookshelf without affecting other entries

