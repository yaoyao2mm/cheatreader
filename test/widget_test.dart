// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cheatreader/src/platform_window_controller_base.dart';
import 'package:cheatreader/src/reader_app.dart';
import 'package:cheatreader/src/reader_controller.dart';
import 'package:cheatreader/src/reader_file_bookmark_service.dart';
import 'package:cheatreader/src/reader_import_service.dart';
import 'package:cheatreader/src/reader_library_storage.dart';
import 'package:cheatreader/src/reader_layout_metrics.dart';
import 'package:cheatreader/src/reader_preferences.dart';
import 'package:cheatreader/src/reader_settings.dart';
import 'package:cheatreader/src/reader_shortcuts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the reader surface without app chrome', (
    WidgetTester tester,
  ) async {
    final controller = ReaderController(
      initialContent: '第一行\n第二行\n第三行',
      preferencesStore: MemoryReaderPreferencesStore(),
      windowController: _FakePlatformWindowController(),
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: _FakePlatformWindowController(),
      ),
    );

    expect(find.textContaining('第一行'), findsOneWidget);
    expect(find.textContaining('第二行'), findsOneWidget);

    final decoratedBoxes = tester.widgetList<Container>(
      find.byWidgetPredicate(
        (widget) => widget is Container && widget.decoration is BoxDecoration,
      ),
    );
    final readerContainer = decoratedBoxes.firstWhere(
      (container) =>
          (container.decoration as BoxDecoration).color != null &&
          container.padding ==
              const EdgeInsets.symmetric(
                horizontal: readerHorizontalPadding,
                vertical: readerMultiLineVerticalPadding,
              ),
    );
    final decoration = readerContainer.decoration! as BoxDecoration;
    expect(decoration.border, isNull);
  });

  testWidgets('single-line mode keeps text to one visual line', (
    WidgetTester tester,
  ) async {
    final controller = ReaderController(
      initialContent: '这是一段很长很长很长很长很长很长的单行文本，用来验证单行模式不会自动换行',
      preferencesStore: MemoryReaderPreferencesStore(
        initialSettings: ReaderSettings.defaults.copyWith(oneLineMode: true),
      ),
      windowController: _FakePlatformWindowController(),
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      SizedBox(
        width: 320,
        height: 48,
        child: CheatReaderApp(
          controller: controller,
          windowController: _FakePlatformWindowController(),
        ),
      ),
    );

    expect(find.textContaining('这是一段很长很长'), findsOneWidget);
    final text = tester.widget<Text>(find.byType(Text).first);
    expect(text.softWrap, isFalse);
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.clip);

    final readerContainer = tester
        .widgetList<Container>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container && widget.decoration is BoxDecoration,
          ),
        )
        .firstWhere(
          (container) =>
              (container.decoration as BoxDecoration).color != null &&
              container.padding ==
                  const EdgeInsets.symmetric(
                    horizontal: readerHorizontalPadding,
                    vertical: readerOneLineVerticalPadding,
                  ),
        );
    expect(
      readerContainer.padding,
      const EdgeInsets.symmetric(
        horizontal: readerHorizontalPadding,
        vertical: readerOneLineVerticalPadding,
      ),
    );
  });

  testWidgets('transparent mode removes reader background fill', (
    WidgetTester tester,
  ) async {
    final controller = ReaderController(
      initialContent: '透明模式测试',
      preferencesStore: MemoryReaderPreferencesStore(
        initialSettings: ReaderSettings.defaults.copyWith(
          transparentModeEnabled: true,
        ),
      ),
      windowController: _FakePlatformWindowController(),
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: _FakePlatformWindowController(),
      ),
    );

    final readerContainer = tester
        .widgetList<Container>(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container && widget.decoration is BoxDecoration,
          ),
        )
        .firstWhere(
          (container) =>
              (container.decoration as BoxDecoration).color != null &&
              container.padding ==
                  const EdgeInsets.symmetric(
                    horizontal: readerHorizontalPadding,
                    vertical: readerMultiLineVerticalPadding,
                  ),
        );
    final decoration = readerContainer.decoration! as BoxDecoration;
    expect(decoration.color, Colors.transparent);
  });

  testWidgets(
    'automatic text color adapts when the reader background turns light',
    (WidgetTester tester) async {
      final controller = ReaderController(
        initialContent: '自动配色测试',
        preferencesStore: MemoryReaderPreferencesStore(
          initialSettings: ReaderSettings.defaults.copyWith(windowOpacity: 0.4),
        ),
        windowController: _FakePlatformWindowController(),
        fileBookmarkService: _FakeReaderFileBookmarkService(),
        importService: _FakeReaderImportService(),
        libraryStorage: MemoryReaderLibraryStorage(),
      );
      await controller.initialize();

      await tester.pumpWidget(
        CheatReaderApp(
          controller: controller,
          windowController: _FakePlatformWindowController(),
        ),
      );

      final text = tester.widget<Text>(find.text('自动配色测试'));
      expect(text.style?.color, const Color(0xFF111111));
      expect(text.style?.shadows, isEmpty);
    },
  );

  testWidgets('automatic text brightness can dim the default light text', (
    WidgetTester tester,
  ) async {
    final controller = ReaderController(
      initialContent: '自动亮度测试',
      preferencesStore: MemoryReaderPreferencesStore(
        initialSettings: ReaderSettings.defaults.copyWith(
          textBrightnessFactor: 0.5,
        ),
      ),
      windowController: _FakePlatformWindowController(),
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: _FakePlatformWindowController(),
      ),
    );

    final text = tester.widget<Text>(find.text('自动亮度测试'));
    final expected = _dimmedColor(
      const Color(ReaderSettings.defaultCustomTextColorValue),
      0.5,
    );
    expect(text.style?.color, expected);
    expect(text.style?.shadows, isEmpty);
  });

  testWidgets('custom text color works with custom opacity', (
    WidgetTester tester,
  ) async {
    final controller = ReaderController(
      initialContent: '自定义字色测试',
      preferencesStore: MemoryReaderPreferencesStore(
        initialSettings: ReaderSettings.defaults.copyWith(
          windowOpacity: 0.35,
          textColorMode: ReaderTextColorMode.custom,
          customTextColorValue: 0xFFD97706,
        ),
      ),
      windowController: _FakePlatformWindowController(),
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: _FakePlatformWindowController(),
      ),
    );

    final text = tester.widget<Text>(find.text('自定义字色测试'));
    expect(text.style?.color, const Color(0xFFD97706));
    expect(text.style?.shadows, isEmpty);
  });

  testWidgets(
    'transparent mode keeps custom text color readable with shadows',
    (WidgetTester tester) async {
      final controller = ReaderController(
        initialContent: '透明模式测试',
        preferencesStore: MemoryReaderPreferencesStore(
          initialSettings: ReaderSettings.defaults.copyWith(
            transparentModeEnabled: true,
            textColorMode: ReaderTextColorMode.custom,
            customTextColorValue: 0xFF111111,
          ),
        ),
        windowController: _FakePlatformWindowController(),
        fileBookmarkService: _FakeReaderFileBookmarkService(),
        importService: _FakeReaderImportService(),
        libraryStorage: MemoryReaderLibraryStorage(),
      );
      await controller.initialize();

      await tester.pumpWidget(
        CheatReaderApp(
          controller: controller,
          windowController: _FakePlatformWindowController(),
        ),
      );

      final text = tester.widget<Text>(find.text('透明模式测试'));
      expect(text.style?.color, const Color(0xFF111111));
      expect(text.style?.shadows, isNotEmpty);
    },
  );

  testWidgets('custom shortcut advances reading', (WidgetTester tester) async {
    final controller = ReaderController(
      initialContent: '第一行\n第二行\n第三行',
      preferencesStore: MemoryReaderPreferencesStore(
        initialSettings: ReaderSettings.defaults.copyWith(
          shortcutBindings: ReaderShortcutBindings.defaults.copyWith(
            nextLine: ReaderShortcutKey.keyJ,
          ),
        ),
      ),
      windowController: _FakePlatformWindowController(),
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: _FakePlatformWindowController(),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    await tester.pumpAndSettle();

    expect(find.textContaining('第二行'), findsOneWidget);
  });

  testWidgets('arbitrary custom shortcut advances reading', (
    WidgetTester tester,
  ) async {
    final controller = ReaderController(
      initialContent: '第一行\n第二行\n第三行',
      preferencesStore: MemoryReaderPreferencesStore(
        initialSettings: ReaderSettings.defaults.copyWith(
          shortcutBindings: ReaderShortcutBindings.defaults.copyWith(
            nextLine: ReaderShortcutKey(
              logicalKeyId: LogicalKeyboardKey.f5.keyId,
            ),
          ),
        ),
      ),
      windowController: _FakePlatformWindowController(),
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: _FakePlatformWindowController(),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.f5);
    await tester.pumpAndSettle();

    expect(find.textContaining('第二行'), findsOneWidget);
  });

  testWidgets('locate shortcut asks window controller to reveal reader', (
    WidgetTester tester,
  ) async {
    final windowController = _FakePlatformWindowController(
      floatingControls: true,
    );
    final controller = ReaderController(
      initialContent: '第一行\n第二行\n第三行',
      preferencesStore: MemoryReaderPreferencesStore(),
      windowController: windowController,
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: windowController,
      ),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyF);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(windowController.locateReaderCount, 1);
  });

  testWidgets('reading animation is disabled by default', (
    WidgetTester tester,
  ) async {
    final controller = ReaderController(
      initialContent: '第一行\n第二行\n第三行',
      preferencesStore: MemoryReaderPreferencesStore(),
      windowController: _FakePlatformWindowController(),
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: _FakePlatformWindowController(),
      ),
    );

    expect(controller.settings.readingAnimationEnabled, isFalse);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(find.textContaining('第二行'), findsOneWidget);
    expect(find.byType(TweenAnimationBuilder<double>), findsNothing);
  });

  testWidgets(
    'multi-line mode advances wrapped text one visual line at a time',
    (WidgetTester tester) async {
      final controller = ReaderController(
        initialContent: '这是一段很长很长很长很长很长很长的文本，用来验证多行模式会按视觉行推进，而不是整段突然跳走。\n第二段',
        preferencesStore: MemoryReaderPreferencesStore(),
        windowController: _FakePlatformWindowController(),
        fileBookmarkService: _FakeReaderFileBookmarkService(),
        importService: _FakeReaderImportService(),
        libraryStorage: MemoryReaderLibraryStorage(),
      );
      await controller.initialize();

      await tester.pumpWidget(
        SizedBox(
          width: 220,
          height: 72,
          child: CheatReaderApp(
            controller: controller,
            windowController: _FakePlatformWindowController(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(TweenAnimationBuilder<double>), findsNothing);

      final beforeText = tester.widget<Text>(find.byType(Text).first).data;

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      final afterText = tester.widget<Text>(find.byType(Text).first).data;
      expect(beforeText, isNotNull);
      expect(afterText, isNotNull);
      expect(afterText, isNot(beforeText));
      expect(controller.currentLineIndex, 0);
    },
  );

  testWidgets('page navigation follows wrapped lines after window resize', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(640, 72);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final controller = ReaderController(
      initialContent: '第一段\n第二段在窄窗口中会换成多个视觉行，翻页时不能跳过未显示的部分。\n第三段',
      preferencesStore: MemoryReaderPreferencesStore(),
      windowController: _FakePlatformWindowController(),
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: _FakePlatformWindowController(),
      ),
    );
    await tester.pump();

    tester.view.physicalSize = const Size(220, 72);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
    await tester.pumpAndSettle();

    expect(controller.currentLineIndex, 1);
    expect(find.textContaining('第三段'), findsNothing);
  });

  testWidgets('custom page shortcuts keep one visual line of context', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(760, 132);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final controller = ReaderController(
      initialContent: List<String>.generate(
        12,
        (index) => 'LINE-${index + 1}',
      ).join('\n'),
      preferencesStore: MemoryReaderPreferencesStore(
        initialSettings: ReaderSettings.defaults.copyWith(
          lineSpacing: ReaderSettings.minLineSpacing,
          shortcutBindings: ReaderShortcutBindings.defaults.copyWith(
            nextPage: ReaderShortcutKey.keyN,
            previousPage: ReaderShortcutKey.keyP,
          ),
        ),
      ),
      windowController: _FakePlatformWindowController(),
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: _FakePlatformWindowController(),
      ),
    );
    await tester.pump();

    expect(
      tester.widget<Text>(find.byType(Text).first).data,
      'LINE-1\nLINE-2\nLINE-3\nLINE-4\nLINE-5',
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byType(Text).first).data,
      'LINE-5\nLINE-6\nLINE-7\nLINE-8\nLINE-9',
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.byType(Text).first).data,
      'LINE-1\nLINE-2\nLINE-3\nLINE-4\nLINE-5',
    );
  });

  testWidgets('can disable punctuation-preferred visual wrapping', (
    WidgetTester tester,
  ) async {
    const content = '甲乙丙丁戊，己庚辛壬癸子丑寅卯辰巳午未申酉戌亥';
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(260, 96);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    Future<String> displayedText({
      required bool preferPunctuationLineBreaks,
    }) async {
      final controller = ReaderController(
        initialContent: content,
        preferencesStore: MemoryReaderPreferencesStore(
          initialSettings: ReaderSettings.defaults.copyWith(
            preferPunctuationLineBreaks: preferPunctuationLineBreaks,
          ),
        ),
        windowController: _FakePlatformWindowController(),
        fileBookmarkService: _FakeReaderFileBookmarkService(),
        importService: _FakeReaderImportService(),
        libraryStorage: MemoryReaderLibraryStorage(),
      );
      await controller.initialize();

      await tester.pumpWidget(
        CheatReaderApp(
          controller: controller,
          windowController: _FakePlatformWindowController(),
        ),
      );
      await tester.pump();

      return tester.widget<Text>(find.byType(Text).first).data!;
    }

    final punctuationPreferred = await displayedText(
      preferPunctuationLineBreaks: true,
    );
    final compact = await displayedText(preferPunctuationLineBreaks: false);

    final punctuationPreferredFirstLine = punctuationPreferred
        .split('\n')
        .first;
    final compactFirstLine = compact.split('\n').first;
    expect(punctuationPreferredFirstLine, endsWith('，'));
    expect(
      compactFirstLine.length,
      greaterThan(punctuationPreferredFirstLine.length),
    );
  });

  testWidgets('reading animation can be enabled explicitly', (
    WidgetTester tester,
  ) async {
    final controller = ReaderController(
      initialContent: '第一行\n第二行\n第三行',
      preferencesStore: MemoryReaderPreferencesStore(
        initialSettings: ReaderSettings.defaults.copyWith(
          readingAnimationEnabled: true,
        ),
      ),
      windowController: _FakePlatformWindowController(),
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: _FakePlatformWindowController(),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(find.byType(TweenAnimationBuilder<double>), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.textContaining('第二行'), findsOneWidget);
  });

  testWidgets('boss key shortcut hides through the window controller', (
    WidgetTester tester,
  ) async {
    final windowController = _FakePlatformWindowController();
    final controller = ReaderController(
      initialContent: '第一行\n第二行\n第三行',
      preferencesStore: MemoryReaderPreferencesStore(
        initialSettings: ReaderSettings.defaults.copyWith(
          shortcutBindings: ReaderShortcutBindings.defaults.copyWith(
            bossKey: ReaderShortcutKey.keyB,
          ),
        ),
      ),
      windowController: windowController,
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: windowController,
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.keyB);
    await tester.pump();

    expect(windowController.hideForBossKeyCount, 1);
    expect(controller.shouldShowTrayIcon, isTrue);
  });

  testWidgets('english language mode localizes the control panel', (
    WidgetTester tester,
  ) async {
    final controller = ReaderController(
      initialContent: 'Demo line one\nDemo line two',
      preferencesStore: MemoryReaderPreferencesStore(
        initialSettings: ReaderSettings.defaults.copyWith(
          languageMode: ReaderLanguageMode.english,
        ),
      ),
      windowController: _FakePlatformWindowController(),
      fileBookmarkService: _FakeReaderFileBookmarkService(),
      importService: _FakeReaderImportService(),
      libraryStorage: MemoryReaderLibraryStorage(),
    );
    await controller.initialize();

    await tester.pumpWidget(
      CheatReaderApp(
        controller: controller,
        windowController: _FakePlatformWindowController(),
      ),
    );

    await tester.tapAt(tester.getCenter(find.byType(GestureDetector).first));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(tester.getCenter(find.byType(GestureDetector).first));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(
      tester.getCenter(find.byType(GestureDetector).first),
      buttons: kSecondaryMouseButton,
    );
    await tester.pumpAndSettle();

    expect(find.text('CheatReader Control Panel'), findsOneWidget);
    expect(find.text('Import ebook'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Reading Settings'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Reading Settings'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('App disguise'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('App disguise'), findsOneWidget);
    expect(find.text('Preset icon'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Check latest version'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Check latest version'), findsOneWidget);
  });
}

Color _dimmedColor(Color color, double factor) {
  final hsl = HSLColor.fromColor(color);
  return hsl.withLightness((hsl.lightness * factor).clamp(0.0, 1.0)).toColor();
}

class _FakeReaderImportService implements ReaderImportService {
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
  Future<ImportedTextFile> openTxtFile(String filePath) {
    throw UnimplementedError();
  }

  @override
  Future<ImportedTextFile?> pickTxtFile() async => null;
}

class _FakeReaderFileBookmarkService implements ReaderFileBookmarkService {
  @override
  Future<String?> createBookmark(String filePath) async => null;

  @override
  Future<ResolvedReaderFileBookmark?> resolveBookmark(String bookmark) async =>
      null;
}

class _FakePlatformWindowController implements PlatformWindowController {
  _FakePlatformWindowController({this.floatingControls = false});

  final bool floatingControls;
  int hideForBossKeyCount = 0;
  int locateReaderCount = 0;

  @override
  bool get supportsFloatingControls => floatingControls;

  @override
  bool get supportsFramelessWindow => false;

  @override
  bool get supportsManualResize => false;

  @override
  bool get supportsBossKey => true;

  @override
  bool get supportsTaskbarIconVisibility => true;

  @override
  bool get supportsTrayIcon => false;

  @override
  Future<void> initialize({ReaderSettings? settings}) async {}

  @override
  Future<void> prepareForControlPanel({required Size screenSize}) async {}

  @override
  Future<void> restoreAfterControlPanel(ReaderSettings settings) async {}

  @override
  Future<void> startDragging() async {}

  @override
  Future<void> resizeWindow(WindowResizeEdge edge, Offset delta) async {}

  @override
  Future<void> hideForBossKey(ReaderSettings settings) async {
    hideForBossKeyCount += 1;
  }

  @override
  Future<void> restoreFromBossKey(ReaderSettings settings) async {}

  @override
  Future<void> syncPresentation(ReaderSettings settings) async {}

  @override
  Future<void> bringToForegroundFromSystemActivation() async {}

  @override
  Future<void> locateReader(ReaderSettings settings) async {
    locateReaderCount += 1;
  }

  @override
  Future<void> closeWindow() async {}
}
