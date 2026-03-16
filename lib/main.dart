import 'package:flutter/widgets.dart';

import 'src/platform_window_controller.dart';
import 'src/reader_app.dart';
import 'src/reader_controller.dart';
import 'src/reader_file_bookmark_service.dart';
import 'src/reader_import_service.dart';
import 'src/reader_library_storage.dart';
import 'src/reader_preferences.dart';

const _demoContent = '''
工作消息刷完以后，阅读器应该还停留在刚才那一行。
它不需要占据桌面中央，也不需要像传统应用一样提醒存在感。
只要在余光里保留一小块可阅读的区域，就足够继续向下读。
一行模式适合把句子藏进屏幕边缘，多行模式适合短暂进入状态。
滚轮向下时往后读一行，滚轮向上时退回一行。
按下方向键时也应该得到完全一致的结果。
按下 PageDown 时，内容整体向前翻过当前可见范围。
按下 PageUp 时，则回到前一页的顶部附近。
右键菜单承担所有即时设置，不出现工具栏，也不需要状态栏。
字体可以略微放大，透明度可以稍微降低，窗口是否置顶也能立刻切换。
如果平台支持无边框窗口，就让它像一张漂浮的纸条。
如果平台不支持，也至少保持简洁和稳定。
这个项目的第一步，不解决书库，不解决同步，也不解决复杂格式。
它只是一个足够轻、足够快、足够不显眼的阅读器。
当你暂停阅读时，当前位置应该始终被保留下来。
当你重新开始时，只需要再次向下滚动，就能顺着刚才的节奏继续。
''';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencesStore = await _createPreferencesStore();
  final windowController = createPlatformWindowController();
  final fileBookmarkService = PlatformReaderFileBookmarkService();
  final importService = FileSelectorReaderImportService();
  final libraryStorage = PlatformReaderLibraryStorage();
  try {
    await windowController.initialize();
  } catch (_) {
    // Fall back to the default behavior if window initialization fails.
  }

  final controller = ReaderController(
    initialContent: _demoContent,
    preferencesStore: preferencesStore,
    windowController: windowController,
    fileBookmarkService: fileBookmarkService,
    importService: importService,
    libraryStorage: libraryStorage,
  );
  try {
    await controller.initialize();
  } catch (_) {
    // Preserve startup on platforms where a desktop plugin may fail.
  }

  runApp(
    CheatReaderApp(controller: controller, windowController: windowController),
  );
}

Future<ReaderPreferencesStore> _createPreferencesStore() async {
  try {
    return await SharedPreferencesReaderPreferencesStore.create();
  } catch (_) {
    return MemoryReaderPreferencesStore();
  }
}
