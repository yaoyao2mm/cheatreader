import 'package:cheatreader/src/reader_book.dart';
import 'package:cheatreader/src/reader_launch_options.dart';
import 'package:cheatreader/src/reader_preferences.dart';
import 'package:cheatreader/src/reader_settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReaderLaunchOptions', () {
    test('parses reset-display arguments', () {
      expect(
        ReaderLaunchOptions.fromArgs(const ['--reset-display']).resetDisplay,
        isTrue,
      );
      expect(
        ReaderLaunchOptions.fromArgs(const ['--safe-mode']).resetDisplay,
        isTrue,
      );
      expect(ReaderLaunchOptions.fromArgs(const []).resetDisplay, isFalse);
    });

    test('resets only display-related settings when requested', () {
      final snapshot = ReaderPreferencesSnapshot(
        settings: ReaderSettings.defaults.copyWith(
          oneLineMode: true,
          transparentModeEnabled: true,
          transparentTextShadowEnabled: false,
          windowOpacity: 0.42,
          textColorMode: ReaderTextColorMode.custom,
          customTextColorValue: 0xFF2B6CB0,
          textBrightnessFactor: 0.55,
          languageMode: ReaderLanguageMode.english,
        ),
        bookshelf: [
          ReaderBookRecord(
            path: '/tmp/book.txt',
            displayName: 'book.txt',
            lastOpenedAt: DateTime(2026, 3, 25),
            lastReadLineIndex: 0,
            burnedLineCount: 0,
            burnModeEnabled: false,
          ),
        ],
      );

      final recovered = applyLaunchOptionsToSnapshot(
        snapshot,
        ReaderLaunchOptions.fromArgs(const ['--reset-display']),
      );

      expect(recovered.settings.oneLineMode, isFalse);
      expect(recovered.settings.transparentModeEnabled, isFalse);
      expect(recovered.settings.transparentTextShadowEnabled, isFalse);
      expect(recovered.settings.windowOpacity, 0.94);
      expect(recovered.settings.textColorMode, ReaderTextColorMode.adaptive);
      expect(recovered.settings.customTextColorValue, 0xFF2B6CB0);
      expect(
        recovered.settings.textBrightnessFactor,
        ReaderSettings.defaultTextBrightnessFactor,
      );
      expect(recovered.settings.languageMode, ReaderLanguageMode.english);
      expect(recovered.bookshelf, same(snapshot.bookshelf));
    });

    test(
      'forces multi-line startup without resetting other display settings',
      () {
        final snapshot = ReaderPreferencesSnapshot(
          settings: ReaderSettings.defaults.copyWith(
            oneLineMode: true,
            transparentModeEnabled: true,
            transparentTextShadowEnabled: false,
            windowOpacity: 0.42,
            textColorMode: ReaderTextColorMode.custom,
            textBrightnessFactor: 0.55,
          ),
          bookshelf: const [],
        );

        final recovered = applyLaunchOptionsToSnapshot(
          snapshot,
          ReaderLaunchOptions.fromArgs(const []),
          forceMultiLineStartup: true,
        );

        expect(recovered.settings.oneLineMode, isFalse);
        expect(recovered.settings.transparentModeEnabled, isTrue);
        expect(recovered.settings.transparentTextShadowEnabled, isFalse);
        expect(recovered.settings.windowOpacity, 0.42);
        expect(recovered.settings.textColorMode, ReaderTextColorMode.custom);
        expect(recovered.settings.textBrightnessFactor, 0.55);
      },
    );
  });
}
