import 'reader_shortcuts.dart';

enum ReaderFontFamilyPreset { system, serif, monospace }

enum ReaderModeToggleTrigger { doubleClick, middleClick, keyboardShortcut }

enum ReaderLanguageMode { system, simplifiedChinese, english }

enum ReaderTextColorMode { adaptive, custom }

class ReaderSettings {
  const ReaderSettings({
    required this.oneLineMode,
    required this.modeToggleTrigger,
    required this.languageMode,
    required this.alwaysOnTop,
    required this.fontScale,
    required this.lineSpacing,
    required this.readingWidthFactor,
    required this.windowOpacity,
    required this.fontFamilyPreset,
    required this.transparentModeEnabled,
    required this.textColorMode,
    required this.customTextColorValue,
    required this.shortcutBindings,
  });

  static const int defaultCustomTextColorValue = 0xFFF4F4F0;

  static const ReaderSettings defaults = ReaderSettings(
    oneLineMode: false,
    modeToggleTrigger: ReaderModeToggleTrigger.doubleClick,
    languageMode: ReaderLanguageMode.system,
    alwaysOnTop: true,
    fontScale: 1.0,
    lineSpacing: 1.5,
    readingWidthFactor: 1.0,
    windowOpacity: 0.94,
    fontFamilyPreset: ReaderFontFamilyPreset.system,
    transparentModeEnabled: false,
    textColorMode: ReaderTextColorMode.adaptive,
    customTextColorValue: defaultCustomTextColorValue,
    shortcutBindings: ReaderShortcutBindings.defaults,
  );

  final bool oneLineMode;
  final ReaderModeToggleTrigger modeToggleTrigger;
  final ReaderLanguageMode languageMode;
  final bool alwaysOnTop;
  final double fontScale;
  final double lineSpacing;
  final double readingWidthFactor;
  final double windowOpacity;
  final ReaderFontFamilyPreset fontFamilyPreset;
  final bool transparentModeEnabled;
  final ReaderTextColorMode textColorMode;
  final int customTextColorValue;
  final ReaderShortcutBindings shortcutBindings;

  ReaderSettings copyWith({
    bool? oneLineMode,
    ReaderModeToggleTrigger? modeToggleTrigger,
    ReaderLanguageMode? languageMode,
    bool? alwaysOnTop,
    double? fontScale,
    double? lineSpacing,
    double? readingWidthFactor,
    double? windowOpacity,
    ReaderFontFamilyPreset? fontFamilyPreset,
    bool? transparentModeEnabled,
    ReaderTextColorMode? textColorMode,
    int? customTextColorValue,
    ReaderShortcutBindings? shortcutBindings,
  }) {
    return ReaderSettings(
      oneLineMode: oneLineMode ?? this.oneLineMode,
      modeToggleTrigger: modeToggleTrigger ?? this.modeToggleTrigger,
      languageMode: languageMode ?? this.languageMode,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      fontScale: fontScale ?? this.fontScale,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      readingWidthFactor: readingWidthFactor ?? this.readingWidthFactor,
      windowOpacity: windowOpacity ?? this.windowOpacity,
      fontFamilyPreset: fontFamilyPreset ?? this.fontFamilyPreset,
      transparentModeEnabled:
          transparentModeEnabled ?? this.transparentModeEnabled,
      textColorMode: textColorMode ?? this.textColorMode,
      customTextColorValue: customTextColorValue ?? this.customTextColorValue,
      shortcutBindings: shortcutBindings ?? this.shortcutBindings,
    );
  }
}
