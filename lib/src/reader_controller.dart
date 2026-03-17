import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'platform_window_controller_base.dart';
import 'reader_book.dart';
import 'reader_file_bookmark_service.dart';
import 'reader_import_service.dart';
import 'reader_library_storage.dart';
import 'reader_localization.dart';
import 'reader_preferences.dart';
import 'reader_settings.dart';

class ReaderController extends ChangeNotifier {
  ReaderController({
    required String initialContent,
    required ReaderPreferencesStore preferencesStore,
    required PlatformWindowController windowController,
    required ReaderFileBookmarkService fileBookmarkService,
    required ReaderImportService importService,
    required ReaderLibraryStorage libraryStorage,
  }) : _preferencesStore = preferencesStore,
       _windowController = windowController,
       _fileBookmarkService = fileBookmarkService,
       _importService = importService,
       _libraryStorage = libraryStorage,
       _fallbackContent = initialContent,
       _fallbackLines = _splitLines(
         initialContent,
         ReaderSettings.defaults.languageMode,
       ),
       _lines = _splitLines(
         initialContent,
         ReaderSettings.defaults.languageMode,
       );

  final ReaderPreferencesStore _preferencesStore;
  final PlatformWindowController _windowController;
  final ReaderFileBookmarkService _fileBookmarkService;
  final ReaderImportService _importService;
  final ReaderLibraryStorage _libraryStorage;
  final String _fallbackContent;
  final List<String> _fallbackLines;

  ReaderSettings _settings = ReaderSettings.defaults;
  List<ReaderBookRecord> _bookshelf = const [];
  final Set<String> _staleBookPaths = <String>{};
  List<String> _lines;
  int _readLineIndex = 0;
  int _burnedLineCount = 0;
  int _pageLineCount = 8;
  String? _currentBookPath;
  String _currentDisplayName = stringsForLanguageMode(
    ReaderSettings.defaults.languageMode,
  ).demoTitle;
  bool _dragTargetActive = false;

  ReaderSettings get settings => _settings;
  List<ReaderBookRecord> get bookshelf =>
      List<ReaderBookRecord>.unmodifiable(_bookshelf);
  bool get dragTargetActive => _dragTargetActive;
  String get currentDisplayName => _currentDisplayName;
  bool get hasImportedBook => _currentBookPath != null;
  ReaderBookRecord? get currentBook => _findBookRecord(_currentBookPath);
  bool get burnModeEnabled => false;
  int get currentLineIndex => _activeStartLineIndex;
  int get totalLineCount => _lines.length;
  int get visibleLineCount => _settings.oneLineMode ? 1 : _pageLineCount;

  int get _activeStartLineIndex =>
      burnModeEnabled ? _burnedLineCount : _readLineIndex;

  List<String> get visibleLines {
    final endIndex = math.min(
      _activeStartLineIndex + visibleLineCount,
      _lines.length,
    );
    return _lines.sublist(_activeStartLineIndex, endIndex);
  }

  String get visibleText => visibleLines.join('\n');

  Future<void> initialize() async {
    final snapshot = await _preferencesStore.loadSnapshot();
    _settings = snapshot.settings;
    _bookshelf = _sortBookshelf(snapshot.bookshelf);
    await _windowController.syncPresentation(_settings);

    if (_bookshelf.isNotEmpty) {
      final didRestore = await _restoreMostRecentBook();
      if (!didRestore) {
        _restoreFallbackContent();
      }
    } else {
      _restoreFallbackContent();
    }

    notifyListeners();
  }

  void updateVisibleLineCapacity(int value) {
    final normalizedValue = math.max(1, value);
    if (_pageLineCount == normalizedValue) {
      return;
    }

    _pageLineCount = normalizedValue;
    _readLineIndex = _clampLineIndex(_readLineIndex);
    _burnedLineCount = _clampLineIndex(_burnedLineCount);
    unawaited(_persistCurrentBookProgress());
    notifyListeners();
  }

  void moveByLines(int delta) {
    if (delta == 0) {
      return;
    }

    final nextIndex = _clampLineIndex(_readLineIndex + delta);
    if (nextIndex == _readLineIndex) {
      return;
    }

    _readLineIndex = nextIndex;
    _onProgressUpdated();
  }

  void nextLine() => moveByLines(1);

  void previousLine() => moveByLines(-1);

  void nextPage() => moveByLines(visibleLineCount);

  void previousPage() => moveByLines(-visibleLineCount);

  void toggleOneLineMode() {
    _updateSettings(_settings.copyWith(oneLineMode: !_settings.oneLineMode));
  }

  void setModeToggleTrigger(ReaderModeToggleTrigger value) {
    _updateSettings(_settings.copyWith(modeToggleTrigger: value));
  }

  void setLanguageMode(ReaderLanguageMode value) {
    _updateSettings(_settings.copyWith(languageMode: value));
  }

  void toggleBurnMode() {
    // Temporarily disabled until the feature is redesigned.
  }

  void setAlwaysOnTop(bool value) {
    _updateSettings(_settings.copyWith(alwaysOnTop: value));
  }

  void setFontFamilyPreset(ReaderFontFamilyPreset value) {
    _updateSettings(_settings.copyWith(fontFamilyPreset: value));
  }

  void setFontScale(double value) {
    _updateSettings(_settings.copyWith(fontScale: value));
  }

  void setWindowOpacity(double value) {
    _updateSettings(_settings.copyWith(windowOpacity: value));
  }

  void setTransparentModeEnabled(bool value) {
    _updateSettings(_settings.copyWith(transparentModeEnabled: value));
  }

  void setDragTargetActive(bool value) {
    if (_dragTargetActive == value) {
      return;
    }

    _dragTargetActive = value;
    notifyListeners();
  }

  bool isBookStale(String path) => _staleBookPaths.contains(path);

  Future<String?> importFromPicker() async {
    try {
      final file = await _importService.pickTxtFile();
      if (file == null) {
        return null;
      }

      return _openImportedFile(file, storedBookPath: file.path);
    } catch (_) {
      return stringsForSettings(_settings).importFailure;
    }
  }

  Future<String?> importFromPath(String path) async {
    return _importFromResolvedPath(path, storedBookPath: path);
  }

  Future<String?> _importFromResolvedPath(
    String path, {
    required String storedBookPath,
    String? existingBookmark,
    String? existingStoredFilePath,
  }) async {
    if (!_importService.isSupportedTextFilePath(path)) {
      return stringsForSettings(_settings).importUnsupportedFormat;
    }

    try {
      final file = await _importService.openTxtFile(path);
      return _openImportedFile(
        file,
        storedBookPath: storedBookPath,
        existingBookmark: existingBookmark,
        existingStoredFilePath: existingStoredFilePath,
      );
    } catch (_) {
      _staleBookPaths.add(storedBookPath);
      notifyListeners();
      return stringsForSettings(_settings).importOpenFailure;
    }
  }

  Future<String?> openBookshelfEntry(String path) async {
    final record = _findBookRecord(path);
    if (record == null) {
      return importFromPath(path);
    }

    return _openBookshelfRecord(record);
  }

  Future<void> removeBookshelfEntry(String path) async {
    final record = _findBookRecord(path);
    final removingCurrentBook = _currentBookPath == path;
    _bookshelf = _bookshelf
        .where((book) => book.path != path)
        .toList(growable: false);
    _staleBookPaths.remove(path);
    await _preferencesStore.saveBookshelf(_bookshelf);
    if (record?.storedFilePath case final storedFilePath?) {
      await _libraryStorage.deleteStoredFile(storedFilePath);
    }

    if (removingCurrentBook) {
      if (_bookshelf.isEmpty) {
        _restoreFallbackContent();
        notifyListeners();
        return;
      }

      final didRestore = await _restoreMostRecentBook();
      if (!didRestore) {
        _restoreFallbackContent();
      }
    }

    notifyListeners();
  }

  int _clampLineIndex(int value) {
    final maxStartIndex = math.max(0, _lines.length - 1);
    return value.clamp(0, maxStartIndex);
  }

  void _onProgressUpdated() {
    notifyListeners();
    unawaited(_persistCurrentBookProgress());
  }

  void _updateSettings(ReaderSettings value) {
    if (_settings.oneLineMode == value.oneLineMode &&
        _settings.modeToggleTrigger == value.modeToggleTrigger &&
        _settings.languageMode == value.languageMode &&
        _settings.alwaysOnTop == value.alwaysOnTop &&
        _settings.fontScale == value.fontScale &&
        _settings.windowOpacity == value.windowOpacity &&
        _settings.fontFamilyPreset == value.fontFamilyPreset &&
        _settings.transparentModeEnabled == value.transparentModeEnabled) {
      return;
    }

    _settings = value;
    _readLineIndex = _clampLineIndex(_readLineIndex);
    _burnedLineCount = _clampLineIndex(_burnedLineCount);
    if (_currentBookPath == null) {
      _currentDisplayName = stringsForSettings(_settings).demoTitle;
      _lines = _splitLines(_fallbackContent, _settings.languageMode);
    }
    notifyListeners();
    unawaited(_persistSettings());
  }

  Future<void> _persistSettings() async {
    await _preferencesStore.saveSettings(_settings);
    await _windowController.syncPresentation(_settings);
  }

  Future<void> _persistCurrentBookProgress() async {
    final record = currentBook;
    if (record == null) {
      return;
    }

    _replaceBookRecord(
      record.copyWith(
        lastReadLineIndex: _readLineIndex,
        burnedLineCount: 0,
        burnModeEnabled: false,
        lastOpenedAt: DateTime.now(),
      ),
    );
    await _preferencesStore.saveBookshelf(_bookshelf);
  }

  Future<String?> _openImportedFile(
    ImportedTextFile file, {
    required String storedBookPath,
    String? existingBookmark,
    String? existingStoredFilePath,
  }) async {
    final existingRecord = _findBookRecord(storedBookPath);
    final displayName = existingRecord?.displayName ?? file.displayName;
    _staleBookPaths.remove(storedBookPath);
    _lines = _splitLines(file.content, _settings.languageMode);
    _currentBookPath = storedBookPath;
    _currentDisplayName = displayName;

    final storedFile = await _libraryStorage.saveImportedFile(
      file,
      existingStoredPath: existingStoredFilePath ?? existingRecord?.storedFilePath,
    );

    final bookmark =
        existingBookmark ??
        existingRecord?.fileBookmark ??
        await _fileBookmarkService.createBookmark(file.path);

    final restoredReadLineIndex = _clampLineIndex(
      existingRecord?.lastReadLineIndex ?? 0,
    );
    _readLineIndex = restoredReadLineIndex;
    _burnedLineCount = 0;

    final updatedRecord =
        (existingRecord ??
                ReaderBookRecord(
                  path: storedBookPath,
                  displayName: displayName,
                  lastOpenedAt: DateTime.now(),
                  lastReadLineIndex: 0,
                  burnedLineCount: 0,
                  burnModeEnabled: false,
                  storedFilePath: storedFile.path,
                  fileBookmark: bookmark,
                ))
            .copyWith(
              displayName: displayName,
              lastOpenedAt: DateTime.now(),
              lastReadLineIndex: _readLineIndex,
              burnedLineCount: 0,
              burnModeEnabled: false,
              storedFilePath: storedFile.path,
              fileBookmark: bookmark,
            );
    _replaceBookRecord(updatedRecord);
    await _preferencesStore.saveBookshelf(_bookshelf);
    notifyListeners();
    return null;
  }

  Future<bool> _restoreMostRecentBook() async {
    if (_bookshelf.isEmpty) {
      return false;
    }

    final message = await _openBookshelfRecord(_bookshelf.first);
    return message == null;
  }

  Future<String?> _openBookshelfRecord(ReaderBookRecord record) async {
    if (record.storedFilePath case final storedFilePath?) {
      final localMessage = await _importFromResolvedPath(
        storedFilePath,
        storedBookPath: record.path,
        existingBookmark: record.fileBookmark,
        existingStoredFilePath: storedFilePath,
      );
      if (localMessage == null) {
        return null;
      }
    }

    var resolvedPath = record.path;
    var resolvedBookmark = record.fileBookmark;

    if (record.fileBookmark case final bookmark?) {
      final resolved = await _fileBookmarkService.resolveBookmark(bookmark);
      if (resolved != null) {
        resolvedPath = resolved.path;
        resolvedBookmark = resolved.refreshedBookmark ?? bookmark;
      }
    }

    return _importFromResolvedPath(
      resolvedPath,
      storedBookPath: record.path,
      existingBookmark: resolvedBookmark,
      existingStoredFilePath: record.storedFilePath,
    );
  }

  ReaderBookRecord? _findBookRecord(String? path) {
    if (path == null) {
      return null;
    }

    for (final book in _bookshelf) {
      if (book.path == path) {
        return book;
      }
    }
    return null;
  }

  void _replaceBookRecord(ReaderBookRecord record) {
    final nextBookshelf = _bookshelf
        .where((book) => book.path != record.path)
        .toList(growable: true);
    nextBookshelf.add(record);
    _bookshelf = _sortBookshelf(nextBookshelf);
  }

  void _restoreFallbackContent() {
    _lines = _splitLines(_fallbackContent, _settings.languageMode);
    _currentBookPath = null;
    _currentDisplayName = stringsForSettings(_settings).demoTitle;
    _readLineIndex = 0;
    _burnedLineCount = 0;
  }

  static List<ReaderBookRecord> _sortBookshelf(
    List<ReaderBookRecord> bookshelf,
  ) {
    final sorted = List<ReaderBookRecord>.from(bookshelf);
    sorted.sort((a, b) => b.lastOpenedAt.compareTo(a.lastOpenedAt));
    return List<ReaderBookRecord>.unmodifiable(sorted);
  }

  static List<String> _splitLines(
    String content,
    ReaderLanguageMode languageMode,
  ) {
    final normalizedLines = content
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((line) => line.trimRight())
        .toList(growable: false);

    if (normalizedLines.isEmpty ||
        normalizedLines.every((line) => line.isEmpty)) {
      return <String>[stringsForLanguageMode(languageMode).emptyText];
    }

    return normalizedLines;
  }
}
