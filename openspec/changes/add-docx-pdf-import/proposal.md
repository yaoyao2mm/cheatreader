## Why

CheatReader already supports several text-first import formats, but users still need to pre-convert common office and reading documents before they can continue in the floating reader. Adding `docx` and `pdf` import now extends the existing extraction-based workflow to the formats users most often have on hand without changing the product into a full rich-format renderer.

## What Changes

- Add `docx` import by extracting readable body text from Office Open XML documents into the existing plain-text reading flow.
- Add `pdf` import by extracting readable text when the PDF contains an accessible text layer, while preserving the current “text-first extraction” model.
- Extend file picking, drag-and-drop validation, and unsupported-format messaging so `docx` and `pdf` appear alongside the current import formats.
- Define quality boundaries for document extraction, including graceful failure for image-only PDFs and best-effort handling for complex layouts such as tables, footnotes, and multi-column pages.
- Add automated coverage for `docx` and `pdf` import success and failure paths.

## Capabilities

### New Capabilities
- `document-text-import`: Import pipeline support for extracting readable plain text from `docx` and `pdf` files into the existing reader and bookshelf flow.

### Modified Capabilities
- None.

## Impact

- Affects `ReaderImportService`, import-format validation, drag-and-drop acceptance, localized import messaging, README format documentation, and import-focused tests.
- Likely introduces one or more new parsing dependencies for `docx` and `pdf` text extraction, with desktop compatibility and license fit needing explicit review.
- Keeps library storage and reading presentation text-based, so no rich document rendering engine or bookshelf schema migration is expected.
