## Context

CheatReader already supports a compact floating reader with basic typography controls, a fixed set of keyboard shortcuts, and a control panel for runtime settings. The next layer of usability work is not a new reader surface, but a richer control system: readers want more comfortable spacing, more control over line length, the ability to choose shortcuts that fit their own workflow, and a fast “hide now, restore later” action that behaves like a boss key.

These requests cut across multiple parts of the current system. Line spacing and reading width affect reader layout and sizing logic. Shortcut customization affects controller intent mapping, settings persistence, and conflict handling. A boss key reaches into the platform window adapter because it needs non-destructive hide/show behavior rather than app exit. That makes this a cross-cutting change worth designing before implementation.

## Goals / Non-Goals

**Goals:**
- Add a configurable line-spacing control that changes how text is laid out in the reader surface.
- Add a configurable reading-width control that narrows or widens the readable text block without forcing raw window resizing as the only tool.
- Add configurable keyboard shortcuts for core reader actions and persist them across sessions.
- Add a boss-key action that can quickly hide the reader window and restore it later without losing reading state.
- Integrate these controls into the existing control panel and persisted settings model.

**Non-Goals:**
- Building a full shortcut editor with arbitrary multi-step key chords.
- Supporting every possible platform-global hotkey behavior outside the running app.
- Adding click-through, tray integration, or process-level stealth behavior as part of the boss key.
- Redesigning the overall control panel layout beyond what is needed to fit the new controls.
- Changing the bookshelf or import architecture.

## Decisions

### 1. Extend the existing reader settings model instead of introducing a parallel preferences store
Line spacing, reading width, shortcut choices, and boss-key settings should live inside the same persisted settings snapshot that already stores mode, font, opacity, and always-on-top preferences.

**Rationale:** These are runtime reader preferences, not document metadata. Keeping them in the current settings flow preserves the controller/store architecture and avoids fragmented persistence.

**Alternatives considered:**
- Store shortcut and boss-key settings in a second preferences object. Rejected because it increases complexity for little gain.
- Treat some controls as session-only. Rejected because shortcut and spacing preferences are expected to stick.

### 2. Model shortcuts as semantic actions mapped to configurable bindings
The reader should continue to expose semantic actions such as next-line, previous-line, page-forward, page-back, mode-toggle, and boss-key-toggle. Shortcut customization should update the binding map, not duplicate action logic in widgets.

**Rationale:** The app already thinks in terms of reader actions. Reusing that abstraction keeps shortcut customization testable and avoids scattering logic across input handlers.

**Alternatives considered:**
- Bind raw keys directly in the widget tree for each new shortcut. Rejected because it becomes brittle once users can remap controls.
- Allow unrestricted arbitrary key combinations from the start. Rejected because it complicates validation and conflict handling.

### 3. Keep shortcut customization within a constrained, app-scoped shortcut model
Shortcut customization should operate only while the app is focused, and should be limited to a curated set of supported key combinations that can be validated for conflicts.

**Rationale:** App-scoped shortcuts fit the current Flutter/desktop architecture and are much more practical than introducing global hotkeys. A constrained model also reduces conflict and portability issues.

**Alternatives considered:**
- Add global OS-level hotkeys for the boss key. Rejected because this crosses into platform-specific background registration and permission complexity.
- Allow any shortcut string users can type. Rejected because invalid or conflicting mappings become hard to reason about.

### 4. Implement the boss key as adapter-level hide/show, not exit/minimize-only
The boss key should call into the platform window controller to hide the current window and later restore it to its previous visible state, rather than quitting the app or always minimizing.

**Rationale:** The user expectation is “make it disappear quickly without losing my place.” Hide/show semantics fit that better than exit, and are more consistent across desktop targets than minimize-only behavior.

**Alternatives considered:**
- Reuse the existing quit action. Rejected because reopening the app is slower and loses the “instant restore” feel.
- Use minimize-only. Rejected because minimize behavior can feel more visible and less predictable than hide/show in a floating utility context.

### 5. Apply reading width inside the reader surface before escalating to window sizing
Reading width should first control the width of the text block within the reader surface; only platform-specific window logic that already exists should continue to govern outer window bounds.

**Rationale:** Users asking for reading width usually want line-length control, not necessarily a different outer window contract. Keeping width as an inner layout control reduces platform complexity and makes the setting portable.

**Alternatives considered:**
- Treat reading width as direct window width. Rejected because it couples text comfort to platform window behavior and fights existing manual resize logic.
- Ignore width in single-line mode. Rejected because line-length control is especially relevant there.

### 6. Apply line spacing through shared text metrics
Line spacing should be represented as a normalized multiplier used consistently in text style and visible-line-capacity calculations.

**Rationale:** The reader already computes visible capacity from text metrics. A shared multiplier avoids drift between layout appearance and navigation/page behavior.

**Alternatives considered:**
- Change only the `TextStyle.height` value. Rejected because it would desynchronize visible-capacity calculations.

## Risks / Trade-offs

- [Too many settings could erode the product’s minimal feel] -> Mitigation: keep the UI concise, use bounded slider/preset controls, and avoid turning the panel into a full preferences app.
- [Shortcut conflicts may confuse users] -> Mitigation: constrain the shortcut set, validate collisions, and preserve sensible defaults.
- [Boss-key behavior may vary across desktop platforms] -> Mitigation: keep it behind the platform adapter and degrade gracefully where hide/show is limited.
- [Reading width and line spacing changes may affect page movement expectations] -> Mitigation: derive visible-line capacity from the same text metrics and revalidate navigation behavior.
- [Users may expect boss key to be a global hotkey] -> Mitigation: document that this change provides an in-app boss key, not a system-wide hidden background hotkey.

## Migration Plan

- Extend persisted reader settings with line spacing, reading width, shortcut bindings, and boss-key state defaults.
- Update the reader controller and shortcut binding layer to resolve actions from configurable settings.
- Add platform window adapter support for hide/show semantics and wire the boss key to it.
- Update reader layout calculations so line spacing and reading width affect both display and navigation capacity consistently.
- Expand control-panel UI and tests for the new settings.
- If any platform has unstable hide/show behavior, keep the setting available only where the adapter can support it safely and fall back elsewhere.

## Open Questions

- Which action set should be remappable in the first release: only navigation/mode/boss key, or also import/control-panel actions?
- Should reading width be a continuous slider, a few presets, or both?
- Should the boss key restore the previous visibility state with the same shortcut, or also expose a secondary explicit restore action in the control panel?
