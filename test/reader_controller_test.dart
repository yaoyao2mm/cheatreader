import 'package:cheatreader/src/platform_window_controller_base.dart';
import 'package:cheatreader/src/reader_book.dart';
import 'package:cheatreader/src/reader_controller.dart';
import 'package:cheatreader/src/reader_file_bookmark_service.dart';
import 'package:cheatreader/src/reader_import_service.dart';
import 'package:cheatreader/src/reader_library_storage.dart';
import 'package:cheatreader/src/reader_preferences.dart';
import 'package:cheatreader/src/reader_settings.dart';
import 'package:cheatreader/src/reader_shortcuts.dart';
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

    test('jumps to requested line number and clamps page metadata', () async {
      final controller = ReaderController(
        initialContent: 'A\nB\nC\nD\nE\nF\nG',
        preferencesStore: MemoryReaderPreferencesStore(),
        windowController: FakePlatformWindowController(),
        fileBookmarkService: FakeReaderFileBookmarkService(),
        importService: FakeReaderImportService(),
        libraryStorage: MemoryReaderLibraryStorage(),
      );

      await controller.initialize();
      controller.updateVisibleLineCapacity(3);

      expect(controller.currentLineNumber, 1);
      expect(controller.currentPageNumber, 1);
      expect(controller.totalPageCount, 3);

      controller.jumpToLineNumber(5);

      expect(controller.currentLineIndex, 4);
      expect(controller.currentLineNumber, 5);
      expect(controller.currentPageNumber, 2);

      controller.jumpToLineNumber(99);

      expect(controller.currentLineIndex, 6);
      expect(controller.currentLineNumber, 7);
      expect(controller.currentPageNumber, 3);
    });

    test('jumps to requested page number using visible line count', () async {
      final controller = ReaderController(
        initialContent: 'A\nB\nC\nD\nE\nF\nG\nH\nI',
        preferencesStore: MemoryReaderPreferencesStore(),
        windowController: FakePlatformWindowController(),
        fileBookmarkService: FakeReaderFileBookmarkService(),
        importService: FakeReaderImportService(),
        libraryStorage: MemoryReaderLibraryStorage(),
      );

      await controller.initialize();
      controller.updateVisibleLineCapacity(4);

      controller.jumpToPageNumber(2);
      expect(controller.currentLineIndex, 4);
      expect(controller.currentPageNumber, 2);

      controller.jumpToPageNumber(99);
      expect(controller.currentLineIndex, 8);
      expect(controller.currentPageNumber, 3);
    });

    test('jumps to requested progress percent across the full book', () async {
      final controller = ReaderController(
        initialContent: 'A\nB\nC\nD\nE\nF\nG\nH\nI',
        preferencesStore: MemoryReaderPreferencesStore(),
        windowController: FakePlatformWindowController(),
        fileBookmarkService: FakeReaderFileBookmarkService(),
        importService: FakeReaderImportService(),
        libraryStorage: MemoryReaderLibraryStorage(),
      );

      await controller.initialize();

      expect(controller.currentProgressPercent, 0);

      controller.jumpToProgressPercent(50);
      expect(controller.currentLineIndex, 4);
      expect(controller.currentProgressPercent, 50);

      controller.jumpToProgressPercent(100);
      expect(controller.currentLineIndex, 8);
      expect(controller.currentProgressPercent, 100);
    });

    test(
      'search jumps to next and previous matching lines with wrap-around',
      () async {
        final controller = ReaderController(
          initialContent: 'Alpha\nBeta target\nGamma\ntarget delta',
          preferencesStore: MemoryReaderPreferencesStore(),
          windowController: FakePlatformWindowController(),
          fileBookmarkService: FakeReaderFileBookmarkService(),
          importService: FakeReaderImportService(),
          libraryStorage: MemoryReaderLibraryStorage(),
        );

        await controller.initialize();

        final first = controller.jumpToSearchMatch('target', forward: true);
        expect(first, 1);
        expect(controller.currentLineIndex, 1);

        final second = controller.jumpToSearchMatch(
          'target',
          forward: true,
          anchorLineIndex: first,
          includeAnchor: false,
        );
        expect(second, 3);
        expect(controller.currentLineIndex, 3);

        final wrapped = controller.jumpToSearchMatch(
          'target',
          forward: true,
          anchorLineIndex: second,
          includeAnchor: false,
        );
        expect(wrapped, 1);

        final previous = controller.jumpToSearchMatch(
          'target',
          forward: false,
          anchorLineIndex: wrapped,
          includeAnchor: false,
        );
        expect(previous, 3);
        expect(controller.currentLineIndex, 3);
      },
    );

    test('entering one-line mode prefers a nearby non-empty line', () async {
      final controller = ReaderController(
        initialContent: '\n\n第一段\n第二段',
        preferencesStore: MemoryReaderPreferencesStore(),
        windowController: FakePlatformWindowController(),
        fileBookmarkService: FakeReaderFileBookmarkService(),
        importService: FakeReaderImportService(),
        libraryStorage: MemoryReaderLibraryStorage(),
      );

      await controller.initialize();
      controller.updateVisibleLineCapacity(3);

      expect(controller.currentLineIndex, 0);
      controller.toggleOneLineMode();

      expect(controller.settings.oneLineMode, isTrue);
      expect(controller.currentLineIndex, 2);
      expect(controller.visibleLines.first, '第一段');
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
      controller.setLanguageMode(ReaderLanguageMode.english);
      controller.setFontFamilyPreset(ReaderFontFamilyPreset.monospace);
      controller.setReadingAnimationEnabled(true);
      controller.setCustomFont(
        path: '/tmp/fonts/demo.ttf',
        displayName: 'demo.ttf',
      );
      controller.setFontScale(1.2);
      controller.setLineSpacing(1.8);
      controller.setReadingWidthFactor(0.7);
      controller.setWindowOpacity(0.78);
      controller.setAlwaysOnTop(true);
      controller.setTransparentModeEnabled(true);
      controller.setTransparentTextShadowEnabled(false);
      controller.setTextBrightnessFactor(0.6);
      controller.setTextColorMode(ReaderTextColorMode.custom);
      controller.setCustomTextColorValue(0xFF2B6CB0);
      final conflictMessage = controller.setShortcutBinding(
        ReaderShortcutAction.bossKey,
        ReaderShortcutKey.keyB,
      );
      await Future<void>.delayed(Duration.zero);

      final saved = await store.loadSnapshot();
      expect(saved.settings.oneLineMode, isTrue);
      expect(
        saved.settings.modeToggleTrigger,
        ReaderModeToggleTrigger.middleClick,
      );
      expect(saved.settings.languageMode, ReaderLanguageMode.english);
      expect(saved.settings.fontFamilyPreset, ReaderFontFamilyPreset.custom);
      expect(saved.settings.readingAnimationEnabled, isTrue);
      expect(saved.settings.customFontPath, '/tmp/fonts/demo.ttf');
      expect(saved.settings.customFontDisplayName, 'demo.ttf');
      expect(saved.settings.fontScale, 1.2);
      expect(saved.settings.lineSpacing, 1.8);
      expect(saved.settings.readingWidthFactor, 0.7);
      expect(saved.settings.windowOpacity, 0.78);
      expect(saved.settings.alwaysOnTop, isTrue);
      expect(saved.settings.transparentModeEnabled, isTrue);
      expect(saved.settings.transparentTextShadowEnabled, isFalse);
      expect(saved.settings.textBrightnessFactor, 0.6);
      expect(saved.settings.textColorMode, ReaderTextColorMode.custom);
      expect(saved.settings.customTextColorValue, 0xFF2B6CB0);
      expect(conflictMessage, isNull);
      expect(windowController.syncedSettings?.oneLineMode, isTrue);
      expect(
        windowController.syncedSettings?.modeToggleTrigger,
        ReaderModeToggleTrigger.middleClick,
      );
      expect(
        windowController.syncedSettings?.languageMode,
        ReaderLanguageMode.english,
      );
      expect(
        windowController.syncedSettings?.fontFamilyPreset,
        ReaderFontFamilyPreset.custom,
      );
      expect(windowController.syncedSettings?.readingAnimationEnabled, isTrue);
      expect(
        windowController.syncedSettings?.customFontPath,
        '/tmp/fonts/demo.ttf',
      );
      expect(
        windowController.syncedSettings?.customFontDisplayName,
        'demo.ttf',
      );
      expect(windowController.syncedSettings?.fontScale, 1.2);
      expect(windowController.syncedSettings?.lineSpacing, 1.8);
      expect(windowController.syncedSettings?.readingWidthFactor, 0.7);
      expect(windowController.syncedSettings?.windowOpacity, 0.78);
      expect(windowController.syncedSettings?.alwaysOnTop, isTrue);
      expect(windowController.syncedSettings?.transparentModeEnabled, isTrue);
      expect(
        windowController.syncedSettings?.transparentTextShadowEnabled,
        isFalse,
      );
      expect(windowController.syncedSettings?.textBrightnessFactor, 0.6);
      expect(
        windowController.syncedSettings?.textColorMode,
        ReaderTextColorMode.custom,
      );
      expect(windowController.syncedSettings?.customTextColorValue, 0xFF2B6CB0);
    });

    test('rejects conflicting shortcut assignments', () async {
      final controller = ReaderController(
        initialContent: 'One\nTwo',
        preferencesStore: MemoryReaderPreferencesStore(),
        windowController: FakePlatformWindowController(),
        fileBookmarkService: FakeReaderFileBookmarkService(),
        importService: FakeReaderImportService(),
        libraryStorage: MemoryReaderLibraryStorage(),
      );

      await controller.initialize();

      final message = controller.setShortcutBinding(
        ReaderShortcutAction.bossKey,
        ReaderShortcutKey.arrowDown,
      );

      expect(message, isNotNull);
      expect(
        controller.settings.shortcutBindings.bossKey,
        ReaderShortcutBindings.defaults.bossKey,
      );
    });

    test('clearing a custom font falls back to the system preset', () async {
      final controller = ReaderController(
        initialContent: 'One\nTwo',
        preferencesStore: MemoryReaderPreferencesStore(
          initialSettings: ReaderSettings.defaults.copyWith(
            fontFamilyPreset: ReaderFontFamilyPreset.custom,
            customFontPath: '/tmp/fonts/demo.ttf',
            customFontDisplayName: 'demo.ttf',
          ),
        ),
        windowController: FakePlatformWindowController(),
        fileBookmarkService: FakeReaderFileBookmarkService(),
        importService: FakeReaderImportService(),
        libraryStorage: MemoryReaderLibraryStorage(),
      );

      await controller.initialize();
      controller.clearCustomFont();

      expect(
        controller.settings.fontFamilyPreset,
        ReaderFontFamilyPreset.system,
      );
      expect(controller.settings.customFontPath, isNull);
      expect(controller.settings.customFontDisplayName, isNull);
    });

    test(
      'entering custom text color mode seeds from the adaptive color',
      () async {
        final controller = ReaderController(
          initialContent: 'One\nTwo',
          preferencesStore: MemoryReaderPreferencesStore(),
          windowController: FakePlatformWindowController(),
          fileBookmarkService: FakeReaderFileBookmarkService(),
          importService: FakeReaderImportService(),
          libraryStorage: MemoryReaderLibraryStorage(),
        );

        await controller.initialize();
        controller.setTextBrightnessFactor(0.5);
        controller.setTextColorMode(ReaderTextColorMode.custom);

        expect(controller.settings.textColorMode, ReaderTextColorMode.custom);
        expect(
          controller.settings.customTextColorValue,
          _dimmedColorValue(ReaderSettings.defaultCustomTextColorValue, 0.5),
        );
      },
    );

    test(
      'boss key toggles hide and restore through window controller',
      () async {
        final windowController = FakePlatformWindowController();
        final controller = ReaderController(
          initialContent: 'One\nTwo',
          preferencesStore: MemoryReaderPreferencesStore(),
          windowController: windowController,
          fileBookmarkService: FakeReaderFileBookmarkService(),
          importService: FakeReaderImportService(),
          libraryStorage: MemoryReaderLibraryStorage(),
        );

        await controller.initialize();
        await controller.toggleBossKey();
        expect(controller.isBossKeyHidden, isTrue);
        expect(windowController.hideForBossKeyCount, 1);

        await controller.toggleBossKey();
        expect(controller.isBossKeyHidden, isFalse);
        expect(windowController.restoreFromBossKeyCount, 1);
      },
    );

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
    test(
      'uses default non-topmost when always-on-top preference is missing',
      () async {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final store = await SharedPreferencesReaderPreferencesStore.create();

        final loaded = await store.loadSnapshot();

        expect(loaded.settings.alwaysOnTop, isFalse);
      },
    );

    test('keeps saved always-on-top value for existing users', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'reader.alwaysOnTop': true,
      });
      final store = await SharedPreferencesReaderPreferencesStore.create();

      final loaded = await store.loadSnapshot();

      expect(loaded.settings.alwaysOnTop, isTrue);
    });

    test('loads previously saved values', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = await SharedPreferencesReaderPreferencesStore.create();
      const settings = ReaderSettings(
        oneLineMode: true,
        modeToggleTrigger: ReaderModeToggleTrigger.keyboardShortcut,
        languageMode: ReaderLanguageMode.english,
        alwaysOnTop: false,
        readingAnimationEnabled: true,
        fontScale: 1.2,
        lineSpacing: 1.8,
        readingWidthFactor: 0.72,
        windowOpacity: 0.78,
        fontFamilyPreset: ReaderFontFamilyPreset.serif,
        customFontPath: '/tmp/fonts/book.ttf',
        customFontDisplayName: 'book.ttf',
        transparentModeEnabled: true,
        transparentTextShadowEnabled: false,
        textColorMode: ReaderTextColorMode.custom,
        customTextColorValue: 0xFF0F766E,
        textBrightnessFactor: 0.6,
        shortcutBindings: ReaderShortcutBindings.defaults,
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
      expect(loaded.settings.lineSpacing, 1.8);
      expect(loaded.settings.readingWidthFactor, 0.72);
      expect(loaded.settings.windowOpacity, 0.78);
      expect(loaded.settings.fontFamilyPreset, ReaderFontFamilyPreset.serif);
      expect(loaded.settings.customFontPath, '/tmp/fonts/book.ttf');
      expect(loaded.settings.customFontDisplayName, 'book.ttf');
      expect(loaded.settings.transparentModeEnabled, isTrue);
      expect(loaded.settings.transparentTextShadowEnabled, isFalse);
      expect(loaded.settings.textBrightnessFactor, 0.6);
      expect(loaded.settings.textColorMode, ReaderTextColorMode.custom);
      expect(loaded.settings.customTextColorValue, 0xFF0F766E);
      expect(loaded.bookshelf.single.path, '/tmp/book.txt');
      expect(loaded.bookshelf.single.burnModeEnabled, isFalse);
      expect(loaded.bookshelf.single.fileBookmark, 'bookmark:/tmp/book.txt');
    });
  });
}

int _dimmedColorValue(int colorValue, double factor) {
  final hsl = HSLColor.fromColor(Color(colorValue));
  return hsl
      .withLightness((hsl.lightness * factor).clamp(0.0, 1.0))
      .toColor()
      .toARGB32();
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
        normalized.endsWith('.fb2') ||
        normalized.endsWith('.docx') ||
        normalized.endsWith('.pdf');
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
  int hideForBossKeyCount = 0;
  int restoreFromBossKeyCount = 0;

  @override
  bool get supportsFloatingControls => true;

  @override
  bool get supportsFramelessWindow => true;

  @override
  bool get supportsManualResize => true;

  @override
  bool get supportsBossKey => true;

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
  Future<void> hideForBossKey(ReaderSettings settings) async {
    hideForBossKeyCount += 1;
  }

  @override
  Future<void> restoreFromBossKey(ReaderSettings settings) async {
    restoreFromBossKeyCount += 1;
  }

  @override
  Future<void> syncPresentation(ReaderSettings settings) async {
    syncedSettings = settings;
  }

  @override
  Future<void> bringToForegroundFromSystemActivation() async {}

  @override
  Future<void> closeWindow() async {}
}
