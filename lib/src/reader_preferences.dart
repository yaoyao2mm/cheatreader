import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'reader_book.dart';
import 'reader_settings.dart';
import 'reader_shortcuts.dart';

class ReaderPreferencesSnapshot {
  const ReaderPreferencesSnapshot({
    required this.settings,
    required this.bookshelf,
  });

  final ReaderSettings settings;
  final List<ReaderBookRecord> bookshelf;
}

abstract class ReaderPreferencesStore {
  Future<ReaderPreferencesSnapshot> loadSnapshot();

  Future<void> saveSettings(ReaderSettings settings);

  Future<void> saveBookshelf(List<ReaderBookRecord> bookshelf);
}

class SharedPreferencesReaderPreferencesStore
    implements ReaderPreferencesStore {
  SharedPreferencesReaderPreferencesStore(this._preferences);

  static const _oneLineModeKey = 'reader.oneLineMode';
  static const _modeToggleTriggerKey = 'reader.modeToggleTrigger';
  static const _languageModeKey = 'reader.languageMode';
  static const _alwaysOnTopKey = 'reader.alwaysOnTop';
  static const _readingAnimationEnabledKey = 'reader.readingAnimationEnabled';
  static const _fontScaleKey = 'reader.fontScale';
  static const _lineSpacingKey = 'reader.lineSpacing';
  static const _readingWidthFactorKey = 'reader.readingWidthFactor';
  static const _windowOpacityKey = 'reader.windowOpacity';
  static const _fontFamilyPresetKey = 'reader.fontFamilyPreset';
  static const _customFontPathKey = 'reader.customFontPath';
  static const _customFontDisplayNameKey = 'reader.customFontDisplayName';
  static const _transparentModeEnabledKey = 'reader.transparentModeEnabled';
  static const _transparentTextShadowEnabledKey =
      'reader.transparentTextShadowEnabled';
  static const _textColorModeKey = 'reader.textColorMode';
  static const _customTextColorValueKey = 'reader.customTextColorValue';
  static const _textBrightnessFactorKey = 'reader.textBrightnessFactor';
  static const _shortcutBindingsKey = 'reader.shortcutBindings';
  static const _bookshelfKey = 'reader.bookshelf';

  final SharedPreferences _preferences;

  static Future<SharedPreferencesReaderPreferencesStore> create() async {
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesReaderPreferencesStore(preferences);
  }

  @override
  Future<ReaderPreferencesSnapshot> loadSnapshot() async {
    return ReaderPreferencesSnapshot(
      settings: ReaderSettings(
        oneLineMode:
            _preferences.getBool(_oneLineModeKey) ??
            ReaderSettings.defaults.oneLineMode,
        modeToggleTrigger: _enumByName(
          ReaderModeToggleTrigger.values,
          _preferences.getString(_modeToggleTriggerKey),
          ReaderSettings.defaults.modeToggleTrigger,
        ),
        languageMode: _enumByName(
          ReaderLanguageMode.values,
          _preferences.getString(_languageModeKey),
          ReaderSettings.defaults.languageMode,
        ),
        alwaysOnTop:
            _preferences.getBool(_alwaysOnTopKey) ??
            ReaderSettings.defaults.alwaysOnTop,
        readingAnimationEnabled:
            _preferences.getBool(_readingAnimationEnabledKey) ??
            ReaderSettings.defaults.readingAnimationEnabled,
        fontScale: _normalizeFontScale(
          _preferences.getDouble(_fontScaleKey) ??
              ReaderSettings.defaults.fontScale,
        ),
        lineSpacing: _normalizeDoubleSetting(
          _preferences.getDouble(_lineSpacingKey) ??
              ReaderSettings.defaults.lineSpacing,
          min: ReaderSettings.minLineSpacing,
          max: ReaderSettings.maxLineSpacing,
          fallback: ReaderSettings.defaults.lineSpacing,
        ),
        readingWidthFactor: _normalizeDoubleSetting(
          _preferences.getDouble(_readingWidthFactorKey) ??
              ReaderSettings.defaults.readingWidthFactor,
          min: ReaderSettings.minReadingWidthFactor,
          max: ReaderSettings.maxReadingWidthFactor,
          fallback: ReaderSettings.defaults.readingWidthFactor,
        ),
        windowOpacity: _normalizeDoubleSetting(
          _preferences.getDouble(_windowOpacityKey) ??
              ReaderSettings.defaults.windowOpacity,
          min: ReaderSettings.minWindowOpacity,
          max: ReaderSettings.maxWindowOpacity,
          fallback: ReaderSettings.defaults.windowOpacity,
        ),
        fontFamilyPreset: _enumByName(
          ReaderFontFamilyPreset.values,
          _preferences.getString(_fontFamilyPresetKey),
          ReaderSettings.defaults.fontFamilyPreset,
        ),
        customFontPath: _preferences.getString(_customFontPathKey),
        customFontDisplayName: _preferences.getString(
          _customFontDisplayNameKey,
        ),
        transparentModeEnabled:
            _preferences.getBool(_transparentModeEnabledKey) ??
            ReaderSettings.defaults.transparentModeEnabled,
        transparentTextShadowEnabled:
            _preferences.getBool(_transparentTextShadowEnabledKey) ??
            ReaderSettings.defaults.transparentTextShadowEnabled,
        textColorMode: _enumByName(
          ReaderTextColorMode.values,
          _preferences.getString(_textColorModeKey),
          ReaderSettings.defaults.textColorMode,
        ),
        customTextColorValue: _normalizeOpaqueColorValue(
          _preferences.getInt(_customTextColorValueKey) ??
              ReaderSettings.defaults.customTextColorValue,
        ),
        textBrightnessFactor: _normalizeTextBrightnessFactor(
          _preferences.getDouble(_textBrightnessFactorKey) ??
              ReaderSettings.defaults.textBrightnessFactor,
        ),
        shortcutBindings: _loadShortcutBindings(),
      ),
      bookshelf: _loadBookshelf(),
    );
  }

  @override
  Future<void> saveSettings(ReaderSettings settings) async {
    await _preferences.setBool(_oneLineModeKey, settings.oneLineMode);
    await _preferences.setString(
      _modeToggleTriggerKey,
      settings.modeToggleTrigger.name,
    );
    await _preferences.setString(_languageModeKey, settings.languageMode.name);
    await _preferences.setBool(_alwaysOnTopKey, settings.alwaysOnTop);
    await _preferences.setBool(
      _readingAnimationEnabledKey,
      settings.readingAnimationEnabled,
    );
    await _preferences.setDouble(
      _fontScaleKey,
      _normalizeFontScale(settings.fontScale),
    );
    await _preferences.setDouble(
      _lineSpacingKey,
      _normalizeDoubleSetting(
        settings.lineSpacing,
        min: ReaderSettings.minLineSpacing,
        max: ReaderSettings.maxLineSpacing,
        fallback: ReaderSettings.defaults.lineSpacing,
      ),
    );
    await _preferences.setDouble(
      _readingWidthFactorKey,
      _normalizeDoubleSetting(
        settings.readingWidthFactor,
        min: ReaderSettings.minReadingWidthFactor,
        max: ReaderSettings.maxReadingWidthFactor,
        fallback: ReaderSettings.defaults.readingWidthFactor,
      ),
    );
    await _preferences.setDouble(
      _windowOpacityKey,
      _normalizeDoubleSetting(
        settings.windowOpacity,
        min: ReaderSettings.minWindowOpacity,
        max: ReaderSettings.maxWindowOpacity,
        fallback: ReaderSettings.defaults.windowOpacity,
      ),
    );
    await _preferences.setString(
      _fontFamilyPresetKey,
      settings.fontFamilyPreset.name,
    );
    if (settings.customFontPath == null || settings.customFontPath!.isEmpty) {
      await _preferences.remove(_customFontPathKey);
    } else {
      await _preferences.setString(
        _customFontPathKey,
        settings.customFontPath!,
      );
    }
    if (settings.customFontDisplayName == null ||
        settings.customFontDisplayName!.isEmpty) {
      await _preferences.remove(_customFontDisplayNameKey);
    } else {
      await _preferences.setString(
        _customFontDisplayNameKey,
        settings.customFontDisplayName!,
      );
    }
    await _preferences.setBool(
      _transparentModeEnabledKey,
      settings.transparentModeEnabled,
    );
    await _preferences.setBool(
      _transparentTextShadowEnabledKey,
      settings.transparentTextShadowEnabled,
    );
    await _preferences.setString(
      _textColorModeKey,
      settings.textColorMode.name,
    );
    await _preferences.setInt(
      _customTextColorValueKey,
      _normalizeOpaqueColorValue(settings.customTextColorValue),
    );
    await _preferences.setDouble(
      _textBrightnessFactorKey,
      _normalizeTextBrightnessFactor(settings.textBrightnessFactor),
    );
    await _preferences.setString(
      _shortcutBindingsKey,
      jsonEncode(settings.shortcutBindings.toJson()),
    );
  }

  @override
  Future<void> saveBookshelf(List<ReaderBookRecord> bookshelf) async {
    await _preferences.setString(
      _bookshelfKey,
      jsonEncode(bookshelf.map((book) => book.toJson()).toList()),
    );
  }

  ReaderShortcutBindings _loadShortcutBindings() {
    final rawShortcutBindings = _preferences.getString(_shortcutBindingsKey);
    if (rawShortcutBindings == null || rawShortcutBindings.isEmpty) {
      return ReaderShortcutBindings.defaults;
    }

    try {
      final decoded = jsonDecode(rawShortcutBindings);
      if (decoded is! Map<String, dynamic>) {
        return ReaderShortcutBindings.defaults;
      }
      return ReaderShortcutBindings.fromJson(decoded);
    } catch (_) {
      return ReaderShortcutBindings.defaults;
    }
  }

  List<ReaderBookRecord> _loadBookshelf() {
    final rawBookshelf = _preferences.getString(_bookshelfKey);
    if (rawBookshelf == null || rawBookshelf.isEmpty) {
      return const <ReaderBookRecord>[];
    }

    try {
      final decoded = jsonDecode(rawBookshelf);
      if (decoded is! List<dynamic>) {
        return const <ReaderBookRecord>[];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ReaderBookRecord.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const <ReaderBookRecord>[];
    }
  }

  T _enumByName<T extends Enum>(List<T> values, String? name, T fallback) {
    if (name == null) {
      return fallback;
    }

    for (final value in values) {
      if (value.name == name) {
        return value;
      }
    }
    return fallback;
  }

  int _normalizeOpaqueColorValue(int value) {
    return 0xFF000000 | (value & 0x00FFFFFF);
  }

  double _normalizeTextBrightnessFactor(double value) {
    if (value.isNaN) {
      return ReaderSettings.defaultTextBrightnessFactor;
    }

    return value
        .clamp(
          ReaderSettings.minTextBrightnessFactor,
          ReaderSettings.maxTextBrightnessFactor,
        )
        .toDouble();
  }

  double _normalizeFontScale(double value) {
    if (value.isNaN) {
      return ReaderSettings.defaults.fontScale;
    }

    return value
        .clamp(ReaderSettings.minFontScale, ReaderSettings.maxFontScale)
        .toDouble();
  }

  double _normalizeDoubleSetting(
    double value, {
    required double min,
    required double max,
    required double fallback,
  }) {
    if (value.isNaN) {
      return fallback;
    }

    return value.clamp(min, max).toDouble();
  }
}

class MemoryReaderPreferencesStore implements ReaderPreferencesStore {
  MemoryReaderPreferencesStore({
    ReaderSettings? initialSettings,
    List<ReaderBookRecord>? initialBookshelf,
  }) : _settings = initialSettings ?? ReaderSettings.defaults,
       _bookshelf = List<ReaderBookRecord>.from(initialBookshelf ?? const []);

  ReaderSettings _settings;
  List<ReaderBookRecord> _bookshelf;

  @override
  Future<ReaderPreferencesSnapshot> loadSnapshot() async {
    return ReaderPreferencesSnapshot(
      settings: _settings,
      bookshelf: List<ReaderBookRecord>.unmodifiable(_bookshelf),
    );
  }

  @override
  Future<void> saveSettings(ReaderSettings settings) async {
    _settings = settings;
  }

  @override
  Future<void> saveBookshelf(List<ReaderBookRecord> bookshelf) async {
    _bookshelf = List<ReaderBookRecord>.from(bookshelf);
  }
}
