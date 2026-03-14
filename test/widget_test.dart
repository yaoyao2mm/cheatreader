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
import 'package:cheatreader/src/reader_preferences.dart';
import 'package:cheatreader/src/reader_settings.dart';
import 'package:flutter/material.dart';
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
              const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
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
        height: 84,
        child: CheatReaderApp(
          controller: controller,
          windowController: _FakePlatformWindowController(),
        ),
      ),
    );

    final text = tester.widget<Text>(find.byType(Text).first);
    expect(text.softWrap, isFalse);
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.clip);
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
            (widget) => widget is Container && widget.decoration is BoxDecoration,
          ),
        )
        .firstWhere(
          (container) =>
              (container.decoration as BoxDecoration).color != null &&
              container.padding ==
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        );
    final decoration = readerContainer.decoration! as BoxDecoration;
    expect(decoration.color, Colors.transparent);
  });
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
        normalized.endsWith('.fb2');
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
  @override
  bool get supportsFloatingControls => false;

  @override
  bool get supportsFramelessWindow => false;

  @override
  bool get supportsManualResize => false;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> prepareForControlPanel({required Size screenSize}) async {}

  @override
  Future<void> restoreAfterControlPanel(ReaderSettings settings) async {}

  @override
  Future<void> startDragging() async {}

  @override
  Future<void> resizeWindow(WindowResizeEdge edge, Offset delta) async {}

  @override
  Future<void> syncPresentation(ReaderSettings settings) async {}
}
