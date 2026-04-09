import 'reader_shortcuts.dart';

enum ReaderFontFamilyPreset { system, serif, monospace, custom }

enum ReaderModeToggleTrigger { doubleClick, middleClick, keyboardShortcut }

enum ReaderLanguageMode { system, simplifiedChinese, english }

enum ReaderTextColorMode { adaptive, custom }

class ReaderSettings {
  const ReaderSettings({
    required this.oneLineMode,
    required this.modeToggleTrigger,
    required this.languageMode,
    required this.alwaysOnTop,
    required this.readingAnimationEnabled,
    required this.fontScale,
    required this.lineSpacing,
    required this.readingWidthFactor,
    required this.windowOpacity,
    required this.fontFamilyPreset,
    required this.customFontPath,
    required this.customFontDisplayName,
    required this.transparentModeEnabled,
    required this.transparentTextShadowEnabled,
    required this.textColorMode,
    required this.customTextColorValue,
    required this.shortcutBindings,
  });

  static const int defaultCustomTextColorValue = 0xFFF4F4F0;

  static const ReaderSettings defaults = ReaderSettings(
    oneLineMode: false,
    modeToggleTrigger: ReaderModeToggleTrigger.doubleClick,
    languageMode: ReaderLanguageMode.system,
    alwaysOnTop: false,
    readingAnimationEnabled: false,
    fontScale: 1.0,
    lineSpacing: 1.5,
    readingWidthFactor: 1.0,
    windowOpacity: 0.94,
    fontFamilyPreset: ReaderFontFamilyPreset.system,
    customFontPath: null,
    customFontDisplayName: null,
    transparentModeEnabled: false,
    transparentTextShadowEnabled: true,
    textColorMode: ReaderTextColorMode.adaptive,
    customTextColorValue: defaultCustomTextColorValue,
    shortcutBindings: ReaderShortcutBindings.defaults,
  );

  final bool oneLineMode;
  final ReaderModeToggleTrigger modeToggleTrigger;
  final ReaderLanguageMode languageMode;
  final bool alwaysOnTop;
  final bool readingAnimationEnabled;
  final double fontScale;
  final double lineSpacing;
  final double readingWidthFactor;
  final double windowOpacity;
  final ReaderFontFamilyPreset fontFamilyPreset;
  final String? customFontPath;
  final String? customFontDisplayName;
  final bool transparentModeEnabled;
  final bool transparentTextShadowEnabled;
  final ReaderTextColorMode textColorMode;
  final int customTextColorValue;
  final ReaderShortcutBindings shortcutBindings;

  static const Object _unset = Object();

  ReaderSettings copyWith({
    bool? oneLineMode,
    ReaderModeToggleTrigger? modeToggleTrigger,
    ReaderLanguageMode? languageMode,
    bool? alwaysOnTop,
    bool? readingAnimationEnabled,
    double? fontScale,
    double? lineSpacing,
    double? readingWidthFactor,
    double? windowOpacity,
    ReaderFontFamilyPreset? fontFamilyPreset,
    Object? customFontPath = _unset,
    Object? customFontDisplayName = _unset,
    bool? transparentModeEnabled,
    bool? transparentTextShadowEnabled,
    ReaderTextColorMode? textColorMode,
    int? customTextColorValue,
    ReaderShortcutBindings? shortcutBindings,
  }) {
    return ReaderSettings(
      oneLineMode: oneLineMode ?? this.oneLineMode,
      modeToggleTrigger: modeToggleTrigger ?? this.modeToggleTrigger,
      languageMode: languageMode ?? this.languageMode,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      readingAnimationEnabled:
          readingAnimationEnabled ?? this.readingAnimationEnabled,
      fontScale: fontScale ?? this.fontScale,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      readingWidthFactor: readingWidthFactor ?? this.readingWidthFactor,
      windowOpacity: windowOpacity ?? this.windowOpacity,
      fontFamilyPreset: fontFamilyPreset ?? this.fontFamilyPreset,
      customFontPath: identical(customFontPath, _unset)
          ? this.customFontPath
          : customFontPath as String?,
      customFontDisplayName: identical(customFontDisplayName, _unset)
          ? this.customFontDisplayName
          : customFontDisplayName as String?,
      transparentModeEnabled:
          transparentModeEnabled ?? this.transparentModeEnabled,
      transparentTextShadowEnabled:
          transparentTextShadowEnabled ?? this.transparentTextShadowEnabled,
      textColorMode: textColorMode ?? this.textColorMode,
      customTextColorValue: customTextColorValue ?? this.customTextColorValue,
      shortcutBindings: shortcutBindings ?? this.shortcutBindings,
    );
  }
}
