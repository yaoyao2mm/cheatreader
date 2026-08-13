import 'reader_shortcuts.dart';

enum ReaderFontFamilyPreset { system, serif, monospace, custom }

enum ReaderModeToggleTrigger { doubleClick, middleClick, keyboardShortcut }

enum ReaderLanguageMode { system, simplifiedChinese, english }

enum ReaderTextColorMode { adaptive, custom }

enum ReaderAutoPageGranularity { page, line }

enum ReaderAppDisguisePreset {
  cheatReader,
  codeEditor,
  devStudio,
  terminal,
  notes,
}

extension ReaderAppDisguisePresetDetails on ReaderAppDisguisePreset {
  String get displayName {
    return switch (this) {
      ReaderAppDisguisePreset.cheatReader => 'CheatReader',
      ReaderAppDisguisePreset.codeEditor => 'Code Editor',
      ReaderAppDisguisePreset.devStudio => 'Dev Studio',
      ReaderAppDisguisePreset.terminal => 'Terminal',
      ReaderAppDisguisePreset.notes => 'Notes',
    };
  }

  String get pngAssetPath {
    return switch (this) {
      ReaderAppDisguisePreset.cheatReader => 'assets/tray_icon.png',
      ReaderAppDisguisePreset.codeEditor => 'assets/disguise/code_editor.png',
      ReaderAppDisguisePreset.devStudio => 'assets/disguise/dev_studio.png',
      ReaderAppDisguisePreset.terminal => 'assets/disguise/terminal.png',
      ReaderAppDisguisePreset.notes => 'assets/disguise/notes.png',
    };
  }

  String get icoAssetPath {
    return switch (this) {
      ReaderAppDisguisePreset.cheatReader => 'assets/tray_icon.ico',
      ReaderAppDisguisePreset.codeEditor => 'assets/disguise/code_editor.ico',
      ReaderAppDisguisePreset.devStudio => 'assets/disguise/dev_studio.ico',
      ReaderAppDisguisePreset.terminal => 'assets/disguise/terminal.ico',
      ReaderAppDisguisePreset.notes => 'assets/disguise/notes.ico',
    };
  }
}

class ReaderSettings {
  const ReaderSettings({
    required this.oneLineMode,
    required this.modeToggleTrigger,
    required this.languageMode,
    required this.appDisguisePreset,
    required this.customAppDisplayName,
    required this.alwaysOnTop,
    required this.hideTaskbarIcon,
    required this.locatorHighlightEnabled,
    required this.readingAnimationEnabled,
    required this.preferPunctuationLineBreaks,
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
    required this.textBrightnessFactor,
    required this.shortcutBindings,
    required this.autoPageEnabled,
    required this.autoPageIntervalSeconds,
    required this.autoPageGranularity,
  });

  static const double minTextBrightnessFactor = 0.35;
  static const double maxTextBrightnessFactor = 1.0;
  static const double defaultTextBrightnessFactor = 1.0;
  static const double minFontScale = 0.5;
  static const double maxFontScale = 1.4;
  static const double minLineSpacing = 1.2;
  static const double maxLineSpacing = 2.0;
  static const double minReadingWidthFactor = 0.55;
  static const double maxReadingWidthFactor = 1.0;
  static const double minWindowOpacity = 0.0;
  static const double maxWindowOpacity = 1.0;
  static const int defaultCustomTextColorValue = 0xFFF4F4F0;
  static const int minAutoPageIntervalSeconds = 1;
  static const int maxAutoPageIntervalSeconds = 60;
  static const int defaultAutoPageIntervalSeconds = 5;

  static const ReaderSettings defaults = ReaderSettings(
    oneLineMode: false,
    modeToggleTrigger: ReaderModeToggleTrigger.doubleClick,
    languageMode: ReaderLanguageMode.system,
    appDisguisePreset: ReaderAppDisguisePreset.cheatReader,
    customAppDisplayName: null,
    alwaysOnTop: false,
    hideTaskbarIcon: false,
    locatorHighlightEnabled: true,
    readingAnimationEnabled: false,
    preferPunctuationLineBreaks: true,
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
    textBrightnessFactor: defaultTextBrightnessFactor,
    shortcutBindings: ReaderShortcutBindings.defaults,
    autoPageEnabled: false,
    autoPageIntervalSeconds: defaultAutoPageIntervalSeconds,
    autoPageGranularity: ReaderAutoPageGranularity.page,
  );

  final bool oneLineMode;
  final ReaderModeToggleTrigger modeToggleTrigger;
  final ReaderLanguageMode languageMode;
  final ReaderAppDisguisePreset appDisguisePreset;
  final String? customAppDisplayName;
  final bool alwaysOnTop;
  final bool hideTaskbarIcon;
  final bool locatorHighlightEnabled;
  final bool readingAnimationEnabled;
  final bool preferPunctuationLineBreaks;
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
  final double textBrightnessFactor;
  final ReaderShortcutBindings shortcutBindings;
  final bool autoPageEnabled;
  final int autoPageIntervalSeconds;
  final ReaderAutoPageGranularity autoPageGranularity;

  static const Object _unset = Object();

  ReaderSettings copyWith({
    bool? oneLineMode,
    ReaderModeToggleTrigger? modeToggleTrigger,
    ReaderLanguageMode? languageMode,
    ReaderAppDisguisePreset? appDisguisePreset,
    Object? customAppDisplayName = _unset,
    bool? alwaysOnTop,
    bool? hideTaskbarIcon,
    bool? locatorHighlightEnabled,
    bool? readingAnimationEnabled,
    bool? preferPunctuationLineBreaks,
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
    double? textBrightnessFactor,
    ReaderShortcutBindings? shortcutBindings,
    bool? autoPageEnabled,
    int? autoPageIntervalSeconds,
    ReaderAutoPageGranularity? autoPageGranularity,
  }) {
    return ReaderSettings(
      oneLineMode: oneLineMode ?? this.oneLineMode,
      modeToggleTrigger: modeToggleTrigger ?? this.modeToggleTrigger,
      languageMode: languageMode ?? this.languageMode,
      appDisguisePreset: appDisguisePreset ?? this.appDisguisePreset,
      customAppDisplayName: identical(customAppDisplayName, _unset)
          ? this.customAppDisplayName
          : customAppDisplayName as String?,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      hideTaskbarIcon: hideTaskbarIcon ?? this.hideTaskbarIcon,
      locatorHighlightEnabled:
          locatorHighlightEnabled ?? this.locatorHighlightEnabled,
      readingAnimationEnabled:
          readingAnimationEnabled ?? this.readingAnimationEnabled,
      preferPunctuationLineBreaks:
          preferPunctuationLineBreaks ?? this.preferPunctuationLineBreaks,
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
      textBrightnessFactor: textBrightnessFactor ?? this.textBrightnessFactor,
      shortcutBindings: shortcutBindings ?? this.shortcutBindings,
      autoPageEnabled: autoPageEnabled ?? this.autoPageEnabled,
      autoPageIntervalSeconds:
          autoPageIntervalSeconds ?? this.autoPageIntervalSeconds,
      autoPageGranularity: autoPageGranularity ?? this.autoPageGranularity,
    );
  }

  String get effectiveAppDisplayName {
    final customName = customAppDisplayName?.trim();
    if (customName != null && customName.isNotEmpty) {
      return customName;
    }
    return appDisguisePreset.displayName;
  }

  String get effectiveTrayIconPngAssetPath => appDisguisePreset.pngAssetPath;

  String get effectiveTrayIconIcoAssetPath => appDisguisePreset.icoAssetPath;
}
