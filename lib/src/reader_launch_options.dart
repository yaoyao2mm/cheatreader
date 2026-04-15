import 'reader_preferences.dart';
import 'reader_settings.dart';

class ReaderLaunchOptions {
  const ReaderLaunchOptions({required this.resetDisplay});

  const ReaderLaunchOptions.defaults() : resetDisplay = false;

  final bool resetDisplay;

  factory ReaderLaunchOptions.fromArgs(List<String> args) {
    final normalizedArgs = args.map((arg) => arg.trim()).toSet();
    return ReaderLaunchOptions(
      resetDisplay:
          normalizedArgs.contains('--reset-display') ||
          normalizedArgs.contains('--safe-mode'),
    );
  }
}

ReaderPreferencesSnapshot applyLaunchOptionsToSnapshot(
  ReaderPreferencesSnapshot snapshot,
  ReaderLaunchOptions options, {
  bool forceMultiLineStartup = false,
}) {
  if (!options.resetDisplay && !forceMultiLineStartup) {
    return snapshot;
  }

  final settings = snapshot.settings;
  final recoveredSettings = settings.copyWith(
    oneLineMode: false,
    transparentModeEnabled: options.resetDisplay
        ? false
        : settings.transparentModeEnabled,
    windowOpacity: options.resetDisplay
        ? (settings.windowOpacity < 0.94 ? 0.94 : settings.windowOpacity)
        : settings.windowOpacity,
    textColorMode: options.resetDisplay
        ? ReaderTextColorMode.adaptive
        : settings.textColorMode,
    textBrightnessFactor: options.resetDisplay
      ? ReaderSettings.defaultTextBrightnessFactor
      : settings.textBrightnessFactor,
  );

  return ReaderPreferencesSnapshot(
    settings: recoveredSettings,
    bookshelf: snapshot.bookshelf,
  );
}
