enum ReaderFontFamilyPreset { system, serif, monospace }
enum ReaderModeToggleTrigger { doubleClick, middleClick, keyboardShortcut }

class ReaderSettings {
  const ReaderSettings({
    required this.oneLineMode,
    required this.modeToggleTrigger,
    required this.alwaysOnTop,
    required this.fontScale,
    required this.windowOpacity,
    required this.fontFamilyPreset,
    required this.transparentModeEnabled,
  });

  static const ReaderSettings defaults = ReaderSettings(
    oneLineMode: false,
    modeToggleTrigger: ReaderModeToggleTrigger.doubleClick,
    alwaysOnTop: true,
    fontScale: 1.0,
    windowOpacity: 0.94,
    fontFamilyPreset: ReaderFontFamilyPreset.system,
    transparentModeEnabled: false,
  );

  final bool oneLineMode;
  final ReaderModeToggleTrigger modeToggleTrigger;
  final bool alwaysOnTop;
  final double fontScale;
  final double windowOpacity;
  final ReaderFontFamilyPreset fontFamilyPreset;
  final bool transparentModeEnabled;

  ReaderSettings copyWith({
    bool? oneLineMode,
    ReaderModeToggleTrigger? modeToggleTrigger,
    bool? alwaysOnTop,
    double? fontScale,
    double? windowOpacity,
    ReaderFontFamilyPreset? fontFamilyPreset,
    bool? transparentModeEnabled,
  }) {
    return ReaderSettings(
      oneLineMode: oneLineMode ?? this.oneLineMode,
      modeToggleTrigger: modeToggleTrigger ?? this.modeToggleTrigger,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      fontScale: fontScale ?? this.fontScale,
      windowOpacity: windowOpacity ?? this.windowOpacity,
      fontFamilyPreset: fontFamilyPreset ?? this.fontFamilyPreset,
      transparentModeEnabled:
          transparentModeEnabled ?? this.transparentModeEnabled,
    );
  }
}
