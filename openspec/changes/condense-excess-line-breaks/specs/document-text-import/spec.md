## MODIFIED Requirements

### Requirement: Docx files can be imported as readable text
The system SHALL allow users to import `.docx` files by extracting readable document body text into the existing plain-text reading flow, and SHALL compact excessive consecutive blank lines in the normalized output.

#### Scenario: Import docx from picker
- **WHEN** a user selects a `.docx` file from the import picker
- **THEN** the system imports the file into the current reading session as extracted plain text with excessive consecutive blank lines compacted

#### Scenario: Import docx from drag and drop
- **WHEN** a user drops a `.docx` file onto the reader surface
- **THEN** the system accepts the file and imports extracted plain text with excessive consecutive blank lines compacted into the current reading session

#### Scenario: Preserve paragraph structure from docx
- **WHEN** a `.docx` file contains body paragraphs and headings
- **THEN** the imported content preserves readable paragraph separation in the normalized plain-text output without retaining long runs of blank lines

### Requirement: Pdf files can be imported when readable text is available
The system SHALL allow users to import `.pdf` files when readable text can be extracted from the document’s text layer, SHALL normalize that text into the existing plain-text reading flow, and SHALL compact excessive consecutive blank lines.

#### Scenario: Import pdf with readable text
- **WHEN** a user imports a `.pdf` file that contains extractable text
- **THEN** the system opens the file as normalized plain text in the reader with excessive consecutive blank lines compacted

#### Scenario: Pdf extraction flattens into reader text
- **WHEN** a `.pdf` file contains multi-page text content
- **THEN** the system combines extracted page text into a readable plain-text sequence suitable for line-based reading without long runs of blank lines
