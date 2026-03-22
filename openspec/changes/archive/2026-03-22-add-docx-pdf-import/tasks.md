## 1. Import foundation

- [x] 1.1 Review and select a desktop-compatible PDF text extraction dependency that fits the project’s license and release constraints.
- [x] 1.2 Extend import format declarations, picker filters, and drag-and-drop validation to recognize `.docx` and `.pdf`.
- [x] 1.3 Update localized supported-format messaging so user-facing import guidance includes the new formats.

## 2. Docx extraction

- [x] 2.1 Implement `.docx` body-text extraction using the existing archive/XML import pipeline.
- [x] 2.2 Normalize `docx` paragraph and heading structure into readable plain-text output for the current reader flow.
- [x] 2.3 Ensure `docx` imports continue through the existing managed-library storage path as normalized `.txt` content.

## 3. Pdf extraction

- [x] 3.1 Integrate PDF text-layer extraction into `ReaderImportService` without introducing rich document rendering.
- [x] 3.2 Normalize extracted multi-page PDF text into a readable plain-text sequence suitable for line-based reading.
- [x] 3.3 Reject PDFs with no usable extracted text through the existing import-failure path instead of creating empty book entries.

## 4. Validation and documentation

- [x] 4.1 Add automated tests for successful `docx` extraction, successful PDF text extraction, and unreadable-PDF failure handling.
- [x] 4.2 Update README format support documentation to describe `docx` support and PDF’s text-extraction boundary.
- [ ] 4.3 Manually validate picker import and drag-and-drop behavior for `docx` and `pdf` on supported desktop targets.
