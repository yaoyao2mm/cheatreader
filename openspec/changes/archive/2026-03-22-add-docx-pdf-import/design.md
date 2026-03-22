## Context

CheatReader already imports several formats by extracting readable text and then storing the normalized result as managed plain text. The current import pipeline is concentrated in `ReaderImportService`, with format filtering, file-picker metadata, drag-and-drop validation, and tests all aligned around a small set of text-first formats. Adding `docx` and `pdf` support therefore extends an existing extraction architecture rather than introducing a new document rendering surface.

The two target formats have very different complexity profiles. `docx` is structurally close to existing `epub` and `fb2` handling because it is an archive of XML parts. `pdf` is structurally much less predictable because readable text depends on whether the document exposes a text layer and how the source layout orders text runs. The design must preserve the project’s “text-first extraction over perfect original-format rendering” direction while making those quality boundaries explicit.

## Goals / Non-Goals

**Goals:**
- Add `docx` import that extracts readable body text into the existing plain-text reading and bookshelf flow.
- Add `pdf` import that extracts readable text from PDFs with a usable text layer and fails gracefully when extraction is not viable.
- Keep the import pipeline architecture text-based so the reader, bookshelf storage, and progress model remain unchanged.
- Expose new formats consistently in picker filters, drag-and-drop validation, user messaging, README format docs, and automated tests.
- Define predictable handling for common document artifacts such as headings, paragraphs, page breaks, and simple tables.

**Non-Goals:**
- Supporting legacy binary `.doc` files in this change.
- Rendering original `docx` or `pdf` layout inside CheatReader.
- Providing OCR for image-only or scanned PDFs.
- Preserving rich formatting such as fonts, colors, floating images, or exact table layout.
- Building a general-purpose office document conversion subsystem outside the current reader import workflow.

## Decisions

### 1. Keep the import contract string-based
The import service will continue to return `ImportedTextFile` with plain-text content, and managed library storage will continue to write normalized `.txt` files.

**Rationale:** The rest of the app already assumes imported books are plain text. Preserving that contract keeps the change isolated to the import surface instead of forcing bookshelf, persistence, and rendering changes.

**Alternatives considered:**
- Store original binary assets and re-parse on every open. Rejected because it adds lifecycle complexity and weakens the current resilient managed-library behavior.
- Introduce a richer intermediate document model. Rejected because the reading surface is intentionally text-only.

### 2. Implement `docx` extraction in-house using the existing archive/XML stack
`docx` support should parse Office Open XML parts using the project’s existing `archive` and `xml` tooling instead of introducing a heavyweight rendering or conversion dependency.

**Rationale:** The codebase already successfully extracts text from archive-backed and XML-backed formats. `docx` fits that pattern closely enough to keep dependency growth low and behavior controllable.

**Alternatives considered:**
- Use an external “convert any Office file to text” package. Rejected because it hides extraction rules and increases dependency risk for a relatively structured format.
- Treat `docx` as unsupported until a full office parser is available. Rejected because `docx` is one of the most practical expansion targets for the existing design.

### 3. Treat `pdf` as text-layer extraction with explicit quality boundaries
`pdf` import should use a dedicated PDF text extraction library or integration that can read text runs from pages, but the feature contract should be “best-effort readable text extraction” rather than layout fidelity.

**Rationale:** PDF support is valuable, but the product direction does not justify embedding a full PDF renderer. Making extraction-only support explicit aligns user expectations with what the reader can realistically present.

**Alternatives considered:**
- Embed a PDF viewer for original-page rendering. Rejected because it conflicts with the text-only reader model and would require a different navigation and persistence architecture.
- Skip PDF entirely. Rejected because it is a common enough source format that users will continue asking for it.

### 4. Fail explicitly when PDF extraction is empty or obviously unusable
If PDF extraction returns no usable text, the import flow should fail with the existing import-failure path rather than creating an empty managed book.

**Rationale:** An empty or nearly empty import is worse than a clear failure because it looks like corrupted reading state. The app should preserve user trust by rejecting PDFs it cannot meaningfully read.

**Alternatives considered:**
- Import empty content and let the reader display nothing. Rejected because it creates confusing bookshelf entries and poor recovery behavior.
- Attempt OCR fallback automatically. Rejected because OCR is out of scope for this change.

### 5. Normalize document structure into paragraph-oriented text
Both `docx` and `pdf` extraction should favor paragraph separation over format fidelity. Headings, paragraph breaks, and simple table cells may be flattened into newline-separated text; complex layout artifacts may be omitted or linearized.

**Rationale:** The current reader experience values readable flow over original formatting. Paragraph-oriented normalization matches the rest of the supported formats and keeps scrolling behavior predictable.

**Alternatives considered:**
- Preserve fine-grained layout markers. Rejected because the one-line and multi-line reader UI cannot exploit them well.
- Strip all structure into a single text block. Rejected because it hurts readability and navigation.

## Risks / Trade-offs

- [PDF extraction quality varies widely across documents] -> Mitigation: define PDF support as best-effort text extraction, reject empty results, and document limitations clearly.
- [Choosing the wrong PDF dependency could hurt desktop portability or release size] -> Mitigation: prefer desktop-compatible extraction libraries and validate Linux/macOS/Windows build impact before implementation completes.
- [`docx` extraction may accidentally include headers, footers, or control XML noise] -> Mitigation: scope extraction to document body content and add fixture-based tests for representative documents.
- [More supported formats will increase user expectations for perfect fidelity] -> Mitigation: keep UI copy and README language centered on “text extraction” rather than “full document support.”
- [Complex documents could produce low-quality bookshelf entries that are hard to debug] -> Mitigation: add targeted tests for `docx` paragraphs and PDF text/no-text cases, and route unusable imports through clear failure paths.

## Migration Plan

- Extend format declarations and validation logic to recognize `docx` and `pdf`.
- Add extraction implementations while preserving the existing `ImportedTextFile -> managed .txt` pipeline.
- Add import tests for successful `docx` extraction, successful PDF text extraction, and PDF failure when no readable text is available.
- Update localized format messaging and README docs to reflect the new support and its text-extraction boundaries.
- If PDF extraction proves too unstable during validation, ship `docx` first and gate PDF behind a follow-up change rather than weakening the import contract.

## Open Questions

- Which PDF extraction dependency offers the best balance of desktop compatibility, license fit, and extraction quality for Flutter desktop release builds?
- Should `docx` extraction include footnotes and endnotes in the initial release, or only body paragraphs?
- What minimum threshold should define an “unusable” PDF extraction result beyond the obvious empty-string case?
