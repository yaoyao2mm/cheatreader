## Context

The change introduces a new reader form factor rather than a standard app screen: a tiny floating surface with no visible window chrome, no status bar, and a mode that can collapse to a single line of text. Flutter can provide the rendering and shared state architecture across platforms, but the frameless and always-on-top behavior depends on desktop window-management integration. The design therefore needs a clean separation between reader presentation, interaction state, and platform window control so the core reader remains portable while desktop platforms receive the floating-window experience the product requires.

## Goals / Non-Goals

**Goals:**
- Deliver a Flutter-based reader shell that supports a frameless, always-floating desktop window.
- Support a minimal reading mode that can render only one visible line while preserving the current reading position.
- Provide fast navigation through mouse wheel and keyboard input for line and page movement.
- Provide a right-click control panel for runtime controls, txt import, bookshelf access, and exit without adding persistent chrome.
- Isolate platform-specific window behavior behind an adapter so the reading experience stays portable across Flutter targets.
- Persist reading progress and mode preferences by imported txt file so reading can resume naturally across sessions.
- Support an optional per-file burn mode that consumes already-read lines from the active queue while leaving the source file untouched.

**Non-Goals:**
- Building a full library manager, sync service, or complex bookshelf UI.
- Defining advanced typography customization beyond the minimal settings needed for first release.
- Guaranteeing identical floating-window behavior on platforms that do not expose always-on-top or frameless APIs through Flutter integrations.
- Solving DRM, store integration, or rich annotation workflows.
- Building a full library manager with categories, search, cover art, or cloud sync.

## Decisions

### 1. Use a layered Flutter architecture with a platform window adapter
The app will separate into: a reader state/controller layer, a presentation layer for the minimal reading surface, and a window control adapter for desktop-specific concerns such as frameless mode, always-on-top, and sizing constraints.

**Rationale:** This keeps the reading logic testable and reusable while containing platform variance in a narrow integration boundary.

**Alternatives considered:**
- Put window management calls directly in widgets. Rejected because it couples UI rendering to platform behavior and makes portability harder.
- Build separate platform shells outside Flutter. Rejected because it undermines the shared multi-platform architecture requested for the project.

### 2. Prioritize desktop targets for floating behavior and degrade gracefully elsewhere
The initial implementation will treat macOS, Windows, and Linux desktop as first-class targets for frameless floating mode. Unsupported targets may render the same reader UI without the full floating-window contract.

**Rationale:** The requested experience depends on OS window management features that are most relevant on desktop. This preserves forward compatibility without blocking the first usable release.

**Alternatives considered:**
- Delay the feature until every Flutter target can behave identically. Rejected because it prevents delivery of the primary use case.
- Support only a single desktop OS. Rejected because Flutter architecture is a stated requirement and multi-platform support should be retained where practical.

### 3. Model navigation in semantic actions instead of raw input handlers
Mouse wheel and keyboard events will map into semantic reader actions such as `nextLine`, `previousLine`, `nextPage`, and `previousPage`. The controller will resolve those actions against the current layout state.

**Rationale:** A semantic action model simplifies testing, shortcut remapping, and future accessibility work.

**Alternatives considered:**
- Handle wheel and key events directly in widgets with inline movement logic. Rejected because it duplicates behavior and makes consistent paging harder.

### 4. Use a context menu as the primary runtime settings surface
The right-click interaction will open a lightweight control panel rather than a tiny native-style menu. That panel will expose txt import, recent-file bookshelf entries, presentation controls, burn-mode toggle, and exit.

**Rationale:** The current scope has outgrown a compact menu. A lightweight panel still preserves the minimal surface during reading while giving enough room for import and bookshelf actions.

**Alternatives considered:**
- Add a persistent toolbar. Rejected because it conflicts with the no-chrome minimal reading goal.
- Hide settings behind a separate modal-only preferences screen. Rejected because it slows down quick in-session adjustments.
- Keep using a small popup menu. Rejected because txt import, bookshelf management, burn-mode toggles, and exit actions no longer fit comfortably.

### 5. Persist reader preferences separately from transient reading position
User preferences such as one-line mode, font scale, opacity, and input preferences will persist between sessions, while reading position will be tracked per imported file so layout changes do not corrupt the stored content model.

**Rationale:** The reader needs stable customization without tying persistence to a specific visual layout, and the user expects the same txt file to resume where it was left.

### 6. Model bookshelf state as lightweight per-file records
The system will store a small bookshelf record per imported txt file, including file path, display name, last-read position, last-opened timestamp, and per-file burn-mode state.

**Rationale:** This supports drag import, menu-based import, quick resume, and a simple bookshelf without introducing a heavyweight library subsystem.

**Alternatives considered:**
- Track only the most recently opened file. Rejected because even a minimal reader benefits from quick switching between a few active txt files.
- Build a full library schema with categories and metadata scraping. Rejected because it exceeds the intended scope.

### 7. Burn mode consumes the in-app queue, not the source file
When burn mode is enabled for a file, advancing through the text will remove already-read lines from the active reading queue or effective viewport, but the original txt file on disk will remain unchanged.

**Rationale:** This delivers the desired disposable reading feel while avoiding destructive file edits, encoding issues, and data loss.

**Alternatives considered:**
- Rewrite the txt file as lines are read. Rejected because it is destructive and too risky for a casual reading tool.

## Risks / Trade-offs

- [Desktop window plugins may behave differently by OS] → Mitigation: keep window control behind an adapter and document platform-specific fallbacks.
- [A one-line presentation can make context loss more likely during navigation] → Mitigation: preserve deterministic line/page movement and make toggling back to larger modes immediate.
- [Mouse wheel behavior may vary by device sensitivity] → Mitigation: normalize wheel delta into semantic actions and keep thresholds configurable.
- [A hidden control panel may reduce discoverability] → Mitigation: keep the right-click interaction consistent and surface import/bookshelf actions prominently in the panel.
- [Always-on-top behavior can feel intrusive] → Mitigation: expose it as a toggle rather than forcing it permanently.
- [External txt files may move or be deleted after import] → Mitigation: show a graceful unavailable state in the bookshelf and allow users to remove stale entries.
- [Burn mode may confuse users if they expect the source file to be edited] → Mitigation: label the mode clearly as view-only consumption and preserve the source file.

## Migration Plan

- Add the new reader shell and state model behind the existing Flutter app entry.
- Integrate desktop window control through a single adapter and validate frameless/always-on-top behavior per supported OS.
- Add minimal-reader settings persistence, bookshelf records, and per-file progress state.
- Implement semantic navigation actions and bind wheel/keyboard inputs.
- Add the right-click control panel and wire it to shared settings state, import flow, bookshelf selection, burn-mode toggle, and exit action.
- Add txt drag-and-drop and menu-based import flows.
- If rollout issues appear, disable floating-mode initialization behind a feature flag or platform gate while retaining the base reader UI.

## Open Questions

- Txt is the only required import format for the current iteration.
- What default keyboard mappings should be considered canonical across macOS and Windows/Linux?
- Click-through behavior remains deferred until the import/library and control-panel workflow is stable.