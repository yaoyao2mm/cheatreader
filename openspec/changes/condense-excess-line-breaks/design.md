## Context

CheatReader already normalizes extracted text in several import paths, but users still encounter documents with long runs of empty lines that create large blank regions during reading. The issue is especially noticeable in OCR-derived and poorly formatted sources. The import pipeline should apply a consistent newline compaction rule so all supported formats enter the reader with stable line density.

## Goals / Non-Goals

**Goals:**
- Compact excessive consecutive line breaks during import so large blank gaps are removed.
- Apply the same newline-compaction rule across supported import formats.
- Keep existing import entry points and error-handling behavior unchanged.
- Keep implementation localized to import normalization logic to minimize regression risk.

**Non-Goals:**
- Building a full typography cleanup engine (hyphenation repair, punctuation rewriting, chapter detection).
- Adding a per-format UI toggle in this change.
- Changing bookshelf/progress persistence semantics.

## Decisions

### 1. Define one deterministic newline compaction rule
Normalize line endings to `\n`, then collapse repeated blank lines so any run of two or more blank separators is reduced to one separator.

Rationale: The user pain is “large blank chunks.” A single deterministic rule is easy to test and prevents format-specific drift.

Alternatives considered:
- Keep current behavior (`\n{3,}` -> `\n\n`). Rejected because two-line blanks still appear frequently and remain visually noisy.
- Add multiple modes or user-tunable thresholds. Rejected for now to keep scope small and apply quickly.

### 2. Reuse the existing shared text-cleaning path
Extend the shared import text cleanup flow and route plain-text (`.txt`) imports through the same cleanup stage used by extracted formats.

Rationale: One shared cleanup path keeps behavior consistent for `txt`, `docx`, `pdf`, and other supported extracted formats.

Alternatives considered:
- Add per-format newline handling. Rejected because behavior would drift and be harder to maintain.

### 3. Preserve existing import failure and support checks
Do not alter unsupported-format checks or extraction failure paths while applying newline compaction.

Rationale: This change is a text-quality improvement, not an import-lifecycle redesign.

## Risks / Trade-offs

- [Paragraph spacing may become denser than some users prefer] -> Mitigation: keep only newline compaction in scope and monitor feedback for optional toggles in a follow-up change.
- [Format-specific regressions if txt path and extracted path diverge] -> Mitigation: apply one shared cleanup function and add tests across representative formats.
- [Hidden regressions in existing extraction output] -> Mitigation: add targeted tests for newline compaction and keep all existing import tests passing.

## Migration Plan

1. Update import normalization logic with deterministic newline compaction.
2. Ensure `.txt` import output passes through the same cleanup rule.
3. Add/adjust automated tests for compacted output and non-regression in existing import behavior.
4. Run `flutter test` and `flutter analyze`.

Rollback strategy:
- Revert newline compaction rule to previous behavior and keep other import logic unchanged.

## Open Questions

- Should future iterations expose an optional toggle for users who want to preserve wide paragraph spacing in certain books?
