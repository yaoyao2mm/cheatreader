# document-text-import Specification

## Purpose
TBD - created by archiving change add-docx-pdf-import. Update Purpose after archive.
## Requirements
### Requirement: Docx files can be imported as readable text
The system SHALL allow users to import `.docx` files by extracting readable document body text into the existing plain-text reading flow.

#### Scenario: Import docx from picker
- **WHEN** a user selects a `.docx` file from the import picker
- **THEN** the system imports the file into the current reading session as extracted plain text

#### Scenario: Import docx from drag and drop
- **WHEN** a user drops a `.docx` file onto the reader surface
- **THEN** the system accepts the file and imports extracted plain text into the current reading session

#### Scenario: Preserve paragraph structure from docx
- **WHEN** a `.docx` file contains body paragraphs and headings
- **THEN** the imported content preserves readable paragraph separation in the normalized plain-text output

### Requirement: Pdf files can be imported when readable text is available
The system SHALL allow users to import `.pdf` files when readable text can be extracted from the document’s text layer, and SHALL normalize that text into the existing plain-text reading flow.

#### Scenario: Import pdf with readable text
- **WHEN** a user imports a `.pdf` file that contains extractable text
- **THEN** the system opens the file as normalized plain text in the reader

#### Scenario: Pdf extraction flattens into reader text
- **WHEN** a `.pdf` file contains multi-page text content
- **THEN** the system combines extracted page text into a readable plain-text sequence suitable for line-based reading

### Requirement: Unsupported or unreadable document imports fail clearly
The system SHALL reject `docx` or `pdf` imports that cannot be converted into usable reader text, and SHALL use the existing import-failure path instead of creating an empty book entry.

#### Scenario: Reject unreadable pdf
- **WHEN** a user imports a `.pdf` file that has no usable extractable text
- **THEN** the system reports import failure and does not create an empty managed library copy

#### Scenario: Reject unsupported extension before extraction
- **WHEN** a user drops or selects a file outside the supported extension list
- **THEN** the system reports the unsupported-format message instead of attempting import

### Requirement: New document formats appear consistently in import affordances
The system SHALL expose `docx` and `pdf` consistently anywhere the app communicates supported import formats.

#### Scenario: File picker exposes docx and pdf
- **WHEN** the user opens the import picker
- **THEN** the picker accepts `.docx` and `.pdf` alongside the existing supported formats

#### Scenario: Import messaging lists docx and pdf
- **WHEN** the app presents import guidance or unsupported-format messaging
- **THEN** `docx` and `pdf` appear in the supported-format text shown to the user

