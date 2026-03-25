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
  static const _shortcutBindingsKey = 'reader.shortcutBindings';
  static const _bookshelfKey = 'reader.bookshelf';

  final SharedPreferences _preferences;

  static Future<SharedPreferencesReaderPreferencesStore> create() async {
    final preferences = await SharedPreferences.getInstance();
    return SharedPreferencesReaderPreferencesStore(preferences);
  }

  @override
  Future<ReaderPreferencesSnapshot> loadSnapshot() async {
    final rawBookshelf = _preferences.getString(_bookshelfKey);
    final decodedBookshelf = rawBookshelf == null
        ? const <dynamic>[]
        : (jsonDecode(rawBookshelf) as List<dynamic>);

    return ReaderPreferencesSnapshot(
      settings: ReaderSettings(
        oneLineMode:
            _preferences.getBool(_oneLineModeKey) ??
            ReaderSettings.defaults.oneLineMode,
        modeToggleTrigger: ReaderModeToggleTrigger.values.byName(
          _preferences.getString(_modeToggleTriggerKey) ??
              ReaderSettings.defaults.modeToggleTrigger.name,
        ),
        languageMode: ReaderLanguageMode.values.byName(
          _preferences.getString(_languageModeKey) ??
              ReaderSettings.defaults.languageMode.name,
        ),
        alwaysOnTop:
            _preferences.getBool(_alwaysOnTopKey) ??
            ReaderSettings.defaults.alwaysOnTop,
        fontScale:
            _preferences.getDouble(_fontScaleKey) ??
            ReaderSettings.defaults.fontScale,
        lineSpacing:
            _preferences.getDouble(_lineSpacingKey) ??
            ReaderSettings.defaults.lineSpacing,
        readingWidthFactor:
            _preferences.getDouble(_readingWidthFactorKey) ??
            ReaderSettings.defaults.readingWidthFactor,
        windowOpacity:
            _preferences.getDouble(_windowOpacityKey) ??
            ReaderSettings.defaults.windowOpacity,
        fontFamilyPreset: ReaderFontFamilyPreset.values.byName(
          _preferences.getString(_fontFamilyPresetKey) ??
              ReaderSettings.defaults.fontFamilyPreset.name,
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
        textColorMode: ReaderTextColorMode.values.byName(
          _preferences.getString(_textColorModeKey) ??
              ReaderSettings.defaults.textColorMode.name,
        ),
        customTextColorValue: _normalizeOpaqueColorValue(
          _preferences.getInt(_customTextColorValueKey) ??
              ReaderSettings.defaults.customTextColorValue,
        ),
        shortcutBindings: _loadShortcutBindings(),
      ),
      bookshelf: decodedBookshelf
          .map(
            (item) => ReaderBookRecord.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
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
    await _preferences.setDouble(_fontScaleKey, settings.fontScale);
    await _preferences.setDouble(_lineSpacingKey, settings.lineSpacing);
    await _preferences.setDouble(
      _readingWidthFactorKey,
      settings.readingWidthFactor,
    );
    await _preferences.setDouble(_windowOpacityKey, settings.windowOpacity);
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

    final decoded = jsonDecode(rawShortcutBindings);
    if (decoded is! Map<String, dynamic>) {
      return ReaderShortcutBindings.defaults;
    }

    try {
      return ReaderShortcutBindings.fromJson(decoded);
    } catch (_) {
      return ReaderShortcutBindings.defaults;
    }
  }

  int _normalizeOpaqueColorValue(int value) {
    return 0xFF000000 | (value & 0x00FFFFFF);
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
