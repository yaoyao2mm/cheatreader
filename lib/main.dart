import 'package:flutter/widgets.dart';

import 'src/platform_window_controller.dart';
import 'src/platform_startup_behavior.dart';
import 'src/reader_app.dart';
import 'src/reader_controller.dart';
import 'src/reader_custom_font.dart';
import 'src/reader_file_bookmark_service.dart';
import 'src/reader_import_service.dart';
import 'src/reader_launch_options.dart';
import 'src/reader_library_storage.dart';
import 'src/reader_localization.dart';
import 'src/reader_preferences.dart';
import 'src/reader_settings.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencesStore = await _createPreferencesStore();
  final launchOptions = ReaderLaunchOptions.fromArgs(args);
  final storedSnapshot = await preferencesStore.loadSnapshot();
  final snapshot = applyLaunchOptionsToSnapshot(
    storedSnapshot,
    launchOptions,
    forceMultiLineStartup: shouldForceMultiLineStartup(),
  );
  if (snapshot.settings.customFontPath case final customFontPath?) {
    await ensureReaderCustomFontLoaded(customFontPath);
  }
  if (!_settingsMatch(storedSnapshot.settings, snapshot.settings)) {
    await preferencesStore.saveSettings(snapshot.settings);
  }
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

bool _settingsMatch(ReaderSettings a, ReaderSettings b) {
  return a.oneLineMode == b.oneLineMode &&
      a.modeToggleTrigger == b.modeToggleTrigger &&
      a.languageMode == b.languageMode &&
      a.alwaysOnTop == b.alwaysOnTop &&
      a.fontScale == b.fontScale &&
      a.lineSpacing == b.lineSpacing &&
      a.readingWidthFactor == b.readingWidthFactor &&
      a.windowOpacity == b.windowOpacity &&
      a.fontFamilyPreset == b.fontFamilyPreset &&
      a.customFontPath == b.customFontPath &&
      a.customFontDisplayName == b.customFontDisplayName &&
      a.transparentModeEnabled == b.transparentModeEnabled &&
      a.textColorMode == b.textColorMode &&
      a.customTextColorValue == b.customTextColorValue &&
      a.shortcutBindings == b.shortcutBindings;
}
