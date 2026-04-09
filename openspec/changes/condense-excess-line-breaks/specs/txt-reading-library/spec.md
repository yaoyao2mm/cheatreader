## ADDED Requirements

### Requirement: Imported txt content compacts excessive consecutive line breaks
The system SHALL compact excessive consecutive blank lines in imported txt content before rendering it in the reader.

#### Scenario: Import txt with large blank gaps
- **WHEN** the user imports a `.txt` file containing runs of consecutive blank lines
- **THEN** the imported reader content collapses each run of consecutive blank lines into a single line separator

#### Scenario: Preserve normal single-line progression
- **WHEN** the user imports a `.txt` file with normal single line breaks
- **THEN** the reader preserves the original line progression without introducing additional blank lines
