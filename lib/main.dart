import 'package:flutter/widgets.dart';

import 'src/platform_window_controller.dart';
import 'src/reader_app.dart';
import 'src/reader_controller.dart';
import 'src/reader_file_bookmark_service.dart';
import 'src/reader_import_service.dart';
import 'src/reader_library_storage.dart';
import 'src/reader_localization.dart';
import 'src/reader_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencesStore = await _createPreferencesStore();
  final snapshot = await preferencesStore.loadSnapshot();
  final launchLocalizations = stringsForSettings(snapshot.settings);
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
    initialContent: launchLocalizations.demoContent,
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
