## 1. Import normalization rule update

- [x] 1.1 Update shared import cleanup logic to normalize line endings and compact excessive consecutive blank lines into a single separator.
- [x] 1.2 Ensure newline compaction is applied in the final normalized output path used by extracted formats (`docx`/`pdf` and other extraction-based formats).
- [x] 1.3 Keep unsupported-format detection and import-failure behavior unchanged while applying the new compaction rule.

## 2. Txt import path alignment

- [x] 2.1 Route `.txt` import output through the same shared cleanup path so newline compaction behavior is consistent.
- [x] 2.2 Verify `.txt` imports with normal line breaks do not gain extra blank lines after cleanup.

## 3. Automated test coverage

- [x] 3.1 Add or update import-service tests for `.txt` content that contains long runs of blank lines and assert compaction result.
- [x] 3.2 Add or update `docx` and `pdf` extraction tests to assert excessive blank-line compaction in normalized output.
- [x] 3.3 Keep all existing import tests passing to confirm no regressions in supported formats and failure paths.

## 4. Validation and quality checks

- [x] 4.1 Run `flutter test` and fix any failures introduced by the normalization change.
- [x] 4.2 Run `flutter analyze` and resolve any new issues.
- [x] 4.3 Perform manual spot checks with sample files containing heavy blank lines to confirm reader output is denser and readable.
