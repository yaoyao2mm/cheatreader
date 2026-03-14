import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'reader_book.dart';
import 'reader_settings.dart';

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
  static const _alwaysOnTopKey = 'reader.alwaysOnTop';
  static const _fontScaleKey = 'reader.fontScale';
  static const _windowOpacityKey = 'reader.windowOpacity';
  static const _fontFamilyPresetKey = 'reader.fontFamilyPreset';
  static const _transparentModeEnabledKey = 'reader.transparentModeEnabled';
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
        alwaysOnTop:
            _preferences.getBool(_alwaysOnTopKey) ??
            ReaderSettings.defaults.alwaysOnTop,
        fontScale:
            _preferences.getDouble(_fontScaleKey) ??
            ReaderSettings.defaults.fontScale,
        windowOpacity:
            _preferences.getDouble(_windowOpacityKey) ??
            ReaderSettings.defaults.windowOpacity,
        fontFamilyPreset: ReaderFontFamilyPreset.values.byName(
          _preferences.getString(_fontFamilyPresetKey) ??
              ReaderSettings.defaults.fontFamilyPreset.name,
        ),
        transparentModeEnabled:
            _preferences.getBool(_transparentModeEnabledKey) ??
            ReaderSettings.defaults.transparentModeEnabled,
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
    await _preferences.setBool(_alwaysOnTopKey, settings.alwaysOnTop);
    await _preferences.setDouble(_fontScaleKey, settings.fontScale);
    await _preferences.setDouble(_windowOpacityKey, settings.windowOpacity);
    await _preferences.setString(
      _fontFamilyPresetKey,
      settings.fontFamilyPreset.name,
    );
    await _preferences.setBool(
      _transparentModeEnabledKey,
      settings.transparentModeEnabled,
    );
  }

  @override
  Future<void> saveBookshelf(List<ReaderBookRecord> bookshelf) async {
    await _preferences.setString(
      _bookshelfKey,
      jsonEncode(bookshelf.map((book) => book.toJson()).toList()),
    );
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
