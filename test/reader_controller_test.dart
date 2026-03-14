import 'package:cheatreader/src/platform_window_controller_base.dart';
import 'package:cheatreader/src/reader_book.dart';
import 'package:cheatreader/src/reader_controller.dart';
import 'package:cheatreader/src/reader_file_bookmark_service.dart';
import 'package:cheatreader/src/reader_import_service.dart';
import 'package:cheatreader/src/reader_library_storage.dart';
import 'package:cheatreader/src/reader_preferences.dart';
import 'package:cheatreader/src/reader_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReaderController', () {
    test('clamps line and page navigation to content bounds', () async {
      final controller = ReaderController(
        initialContent: 'A\nB\nC\nD\nE',
        preferencesStore: MemoryReaderPreferencesStore(),
        windowController: FakePlatformWindowController(),
        fileBookmarkService: FakeReaderFileBookmarkService(),
        importService: FakeReaderImportService(),
        libraryStorage: MemoryReaderLibraryStorage(),
      );

      await controller.initialize();
      controller.updateVisibleLineCapacity(2);

      controller.previousLine();
      expect(controller.currentLineIndex, 0);

      controller.nextLine();
      expect(controller.currentLineIndex, 1);

      controller.nextPage();
      expect(controller.currentLineIndex, 3);

      controller.nextPage();
      expect(controller.currentLineIndex, 4);

      controller.previousPage();
      expect(controller.currentLineIndex, 2);
    });

    test('persists settings changes and syncs window presentation', () async {
      final store = MemoryReaderPreferencesStore();
      final windowController = FakePlatformWindowController();
      final controller = ReaderController(
        initialContent: 'One\nTwo\nThree',
        preferencesStore: store,
        windowController: windowController,
        fileBookmarkService: FakeReaderFileBookmarkService(),
        importService: FakeReaderImportService(),
        libraryStorage: MemoryReaderLibraryStorage(),
      );

      await controller.initialize();
      controller.toggleOneLineMode();
      controller.setModeToggleTrigger(ReaderModeToggleTrigger.middleClick);
      controller.setFontFamilyPreset(ReaderFontFamilyPreset.monospace);
      controller.setFontScale(1.2);
      controller.setWindowOpacity(0.78);
      controller.setTransparentModeEnabled(true);
      await Future<void>.delayed(Duration.zero);

      final saved = await store.loadSnapshot();
      expect(saved.settings.oneLineMode, isTrue);
      expect(
        saved.settings.modeToggleTrigger,
        ReaderModeToggleTrigger.middleClick,
      );
      expect(saved.settings.fontFamilyPreset, ReaderFontFamilyPreset.monospace);
      expect(saved.settings.fontScale, 1.2);
      expect(saved.settings.windowOpacity, 0.78);
      expect(saved.settings.transparentModeEnabled, isTrue);
      expect(windowController.syncedSettings?.oneLineMode, isTrue);
      expect(
        windowController.syncedSettings?.modeToggleTrigger,
        ReaderModeToggleTrigger.middleClick,
      );
      expect(
        windowController.syncedSettings?.fontFamilyPreset,
        ReaderFontFamilyPreset.monospace,
      );
      expect(windowController.syncedSettings?.fontScale, 1.2);
      expect(windowController.syncedSettings?.windowOpacity, 0.78);
      expect(windowController.syncedSettings?.transparentModeEnabled, isTrue);
    });

    test('restores saved progress for imported txt files', () async {
      final store = MemoryReaderPreferencesStore(
        initialBookshelf: [
          ReaderBookRecord(
            path: '/tmp/story.txt',
            displayName: 'story.txt',
            lastOpenedAt: DateTime(2026, 3, 13),
            lastReadLineIndex: 2,
            burnedLineCount: 0,
            burnModeEnabled: false,
            fileBookmark: 'bookmark:/tmp/story.txt',
          ),
        ],
      );
      final controller = ReaderController(
        initialContent: 'fallback',
        preferencesStore: store,
        windowController: FakePlatformWindowController(),
        fileBookmarkService: FakeReaderFileBookmarkService(
          resolvedPaths: {
            'bookmark:/tmp/story.txt': const ResolvedReaderFileBookmark(
              path: '/tmp/story.txt',
            ),
          },
        ),
        importService: FakeReaderImportService(
          files: {'/tmp/story.txt': '一\n二\n三\n四\n五'},
        ),
        libraryStorage: MemoryReaderLibraryStorage(),
      );

      await controller.initialize();

      expect(controller.currentDisplayName, 'story.txt');
      expect(controller.visibleLines.first, '三');
    });

    test('opening a book clears legacy burn mode state', () async {
      final store = MemoryReaderPreferencesStore();
      final controller = ReaderController(
        initialContent: 'fallback',
        preferencesStore: store,
        windowController: FakePlatformWindowController(),
        fileBookmarkService: FakeReaderFileBookmarkService(),
        importService: FakeReaderImportService(
          files: {'/tmp/web.txt': '甲\n乙\n丙\n丁'},
        ),
        libraryStorage: MemoryReaderLibraryStorage(),
      );

      await controller.initialize();
      await controller.importFromPath('/tmp/web.txt');
      await Future<void>.delayed(Duration.zero);

      expect(controller.burnModeEnabled, isFalse);
      expect(controller.visibleLines.first, '甲');

      final snapshot = await store.loadSnapshot();
      final savedBook = snapshot.bookshelf.single;
      expect(savedBook.burnModeEnabled, isFalse);
      expect(savedBook.burnedLineCount, 0);
    });

    test(
      'successful re-import clears stale state and restores content',
      () async {
        final files = <String, String>{};
        final controller = ReaderController(
          initialContent: 'fallback',
          preferencesStore: MemoryReaderPreferencesStore(),
          windowController: FakePlatformWindowController(),
          fileBookmarkService: FakeReaderFileBookmarkService(),
          importService: FakeReaderImportService(files: files),
          libraryStorage: MemoryReaderLibraryStorage(),
        );

        await controller.initialize();

        final firstMessage = await controller.importFromPath('/tmp/retry.txt');
        expect(firstMessage, isNotNull);
        expect(controller.isBookStale('/tmp/retry.txt'), isTrue);

        files['/tmp/retry.txt'] = '重新导入成功';
        final retryMessage = await controller.importFromPath('/tmp/retry.txt');

        expect(retryMessage, isNull);
        expect(controller.isBookStale('/tmp/retry.txt'), isFalse);
        expect(controller.currentDisplayName, 'retry.txt');
        expect(controller.visibleLines.first, '重新导入成功');
      },
    );

    test('restores from managed copy after app restart', () async {
      final files = <String, String>{'/tmp/persist.txt': '第一版\n第二行'};
      final libraryStorage = MemoryReaderLibraryStorage();
      final importService = FakeReaderImportService(
        files: files,
        managedFiles: libraryStorage.files,
      );
      final store = MemoryReaderPreferencesStore();

      final firstController = ReaderController(
        initialContent: 'fallback',
        preferencesStore: store,
        windowController: FakePlatformWindowController(),
        fileBookmarkService: FakeReaderFileBookmarkService(),
        importService: importService,
        libraryStorage: libraryStorage,
      );
      await firstController.initialize();
      await firstController.importFromPath('/tmp/persist.txt');

      files.clear();

      final secondController = ReaderController(
        initialContent: 'fallback',
        preferencesStore: store,
        windowController: FakePlatformWindowController(),
        fileBookmarkService: FakeReaderFileBookmarkService(),
        importService: importService,
        libraryStorage: libraryStorage,
      );
      await secondController.initialize();

      expect(secondController.currentDisplayName, 'persist.txt');
      expect(secondController.visibleLines.first, '第一版');
    });
  });

  group('SharedPreferencesReaderPreferencesStore', () {
    test('loads previously saved values', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = await SharedPreferencesReaderPreferencesStore.create();
      const settings = ReaderSettings(
        oneLineMode: true,
        modeToggleTrigger: ReaderModeToggleTrigger.keyboardShortcut,
        alwaysOnTop: false,
        fontScale: 1.2,
        windowOpacity: 0.78,
        fontFamilyPreset: ReaderFontFamilyPreset.serif,
        transparentModeEnabled: true,
      );

      await store.saveSettings(settings);
      await store.saveBookshelf([
        ReaderBookRecord(
          path: '/tmp/book.txt',
          displayName: 'book.txt',
          lastOpenedAt: DateTime(2026, 3, 13),
          lastReadLineIndex: 3,
          burnedLineCount: 1,
          burnModeEnabled: false,
          fileBookmark: 'bookmark:/tmp/book.txt',
        ),
      ]);
      final loaded = await store.loadSnapshot();

      expect(loaded.settings.oneLineMode, isTrue);
      expect(
        loaded.settings.modeToggleTrigger,
        ReaderModeToggleTrigger.keyboardShortcut,
      );
      expect(loaded.settings.alwaysOnTop, isFalse);
      expect(loaded.settings.fontScale, 1.2);
      expect(loaded.settings.windowOpacity, 0.78);
      expect(loaded.settings.fontFamilyPreset, ReaderFontFamilyPreset.serif);
      expect(loaded.settings.transparentModeEnabled, isTrue);
      expect(loaded.bookshelf.single.path, '/tmp/book.txt');
      expect(loaded.bookshelf.single.burnModeEnabled, isFalse);
      expect(loaded.bookshelf.single.fileBookmark, 'bookmark:/tmp/book.txt');
    });
  });
}

class FakeReaderFileBookmarkService implements ReaderFileBookmarkService {
  FakeReaderFileBookmarkService({
    Map<String, String>? createdBookmarks,
    Map<String, ResolvedReaderFileBookmark>? resolvedPaths,
  }) : createdBookmarks = createdBookmarks ?? const <String, String>{},
       resolvedPaths =
           resolvedPaths ?? const <String, ResolvedReaderFileBookmark>{};

  final Map<String, String> createdBookmarks;
  final Map<String, ResolvedReaderFileBookmark> resolvedPaths;

  @override
  Future<String?> createBookmark(String filePath) async {
    return createdBookmarks[filePath] ?? 'bookmark:$filePath';
  }

  @override
  Future<ResolvedReaderFileBookmark?> resolveBookmark(String bookmark) async {
    return resolvedPaths[bookmark] ??
        ResolvedReaderFileBookmark(
          path: bookmark.replaceFirst('bookmark:', ''),
        );
  }
}

class FakeReaderImportService implements ReaderImportService {
  FakeReaderImportService({
    Map<String, String>? files,
    Map<String, String>? managedFiles,
    this.pickedPath,
  }) : files = files ?? const <String, String>{},
       managedFiles = managedFiles ?? const <String, String>{};

  final Map<String, String> files;
  final Map<String, String> managedFiles;
  final String? pickedPath;

  @override
  bool isSupportedTextFilePath(String filePath) {
    final normalized = filePath.toLowerCase();
    return normalized.endsWith('.txt') ||
        normalized.endsWith('.epub') ||
        normalized.endsWith('.html') ||
        normalized.endsWith('.htm') ||
        normalized.endsWith('.md') ||
        normalized.endsWith('.markdown') ||
        normalized.endsWith('.fb2');
  }

  @override
  Future<ImportedTextFile> openTxtFile(String filePath) async {
    final content = files[filePath] ?? managedFiles[filePath];
    if (content == null) {
      throw Exception('missing file');
    }

    return ImportedTextFile(
      path: filePath,
      displayName: filePath.split('/').last,
      content: content,
    );
  }

  @override
  Future<ImportedTextFile?> pickTxtFile() async {
    if (pickedPath == null) {
      return null;
    }

    return openTxtFile(pickedPath!);
  }
}

class FakePlatformWindowController implements PlatformWindowController {
  ReaderSettings? syncedSettings;

  @override
  bool get supportsFloatingControls => true;

  @override
  bool get supportsFramelessWindow => true;

  @override
  bool get supportsManualResize => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> prepareForControlPanel({required Size screenSize}) async {}

  @override
  Future<void> restoreAfterControlPanel(ReaderSettings settings) async {
    syncedSettings = settings;
  }

  @override
  Future<void> startDragging() async {}

  @override
  Future<void> resizeWindow(WindowResizeEdge edge, Offset delta) async {}

  @override
  Future<void> syncPresentation(ReaderSettings settings) async {
    syncedSettings = settings;
  }
}
