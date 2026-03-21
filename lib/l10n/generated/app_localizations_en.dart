// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CheatReader';

  @override
  String get demoTitle => 'Demo Text';

  @override
  String get emptyText => '(Empty text)';

  @override
  String get untitledText => 'Untitled text';

  @override
  String get demoContent =>
      'After finishing work messages, the reader should still be waiting on the same line.\nIt does not need to take over the center of the desktop, and it does not need to remind you that it exists.\nA small readable area in your peripheral vision is enough to keep moving forward.\nSingle-line mode is for hiding sentences at the edge of the screen, while multi-line mode is for brief focused reading.\nScrolling down moves forward by one line, and scrolling up moves back by one line.\nArrow keys should behave exactly the same way.\nPressing PageDown should move the content forward by the visible reading range.\nPageUp should move back toward the top of the previous reading view.\nThe right-click menu carries all immediate settings, with no toolbar and no status bar.\nThe font can be enlarged a little, opacity can be lowered a little, and always-on-top can be switched instantly.\nIf the platform supports a frameless window, let it feel like a floating note.\nIf it does not, at least keep it simple and stable.\nThe first step of this project is not a full library manager, sync service, or rich-format parser.\nIt just aims to be a reader that is light, fast, and easy to ignore.\nWhen you pause, the current position should always be preserved.\nWhen you return, one more scroll should let you continue from the same rhythm.';

  @override
  String get importNoFiles => 'No importable ebook files found';

  @override
  String get importOpenFailure => 'Could not open this ebook file';

  @override
  String get importFailure => 'Could not import this ebook file';

  @override
  String get importUnsupportedFormat =>
      'Only txt / epub / html / md / fb2 are supported';

  @override
  String get dropPrompt =>
      'Drop txt / epub / html / md / fb2 here to start reading';

  @override
  String get controlPanelTitle => 'CheatReader Control Panel';

  @override
  String get importEbook => 'Import ebook';

  @override
  String get quitReader => 'Quit reader';

  @override
  String get bookshelfTitle => 'Bookshelf';

  @override
  String get bookshelfEmpty =>
      'No imported books yet. You can drag files into the window or use the import button above.';

  @override
  String get settingsTitle => 'Reading Settings';

  @override
  String get modeToggleMethod => 'Display mode switch trigger';

  @override
  String get triggerDoubleClick => 'Double click';

  @override
  String get triggerMiddleClick => 'Middle click';

  @override
  String get triggerKeyboard => 'Shortcut';

  @override
  String get triggerDoubleClickLong => 'Double-click the reader area';

  @override
  String get triggerMiddleClickLong => 'Middle-click the reader area';

  @override
  String get triggerKeyboardLong => 'Press M';

  @override
  String get modeSingleLine => 'single-line';

  @override
  String get modeMultiLine => 'multi-line';

  @override
  String currentModeSummary(Object mode, Object trigger) {
    return 'Current mode: $mode. Trigger: $trigger';
  }

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageZhHans => '简体中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get alwaysOnTopTitle => 'Always on top';

  @override
  String get alwaysOnTopSupported =>
      'Keep the reader floating above other windows';

  @override
  String get alwaysOnTopUnsupported =>
      'This platform does not support it right now';

  @override
  String get transparentModeTitle => 'Transparent mode';

  @override
  String get transparentModeSubtitle =>
      'Remove every background tint and keep text only';

  @override
  String get fontTitle => 'Font';

  @override
  String get fontDefault => 'Default';

  @override
  String get fontSerif => 'Serif';

  @override
  String get fontMonospace => 'Monospace';

  @override
  String get fontScaleLabel => 'Font size';

  @override
  String get windowOpacityLabel => 'Background opacity';

  @override
  String get transparentModeOverridesOpacity =>
      'Controlled by transparent mode';

  @override
  String positionLabel(Object line) {
    return 'Position $line';
  }

  @override
  String get fileMayBeInvalid => 'File may no longer be available';

  @override
  String get removeTooltip => 'Remove';

  @override
  String get sectionSimpleBookshelf => 'Bookshelf';

  @override
  String get sectionReadingSettings => 'Reading Settings';

  @override
  String get sectionAboutApp => 'About';

  @override
  String get appVersionLabel => 'Version';

  @override
  String get appVersionLoading => 'Loading...';

  @override
  String get appVersionUnavailable => 'Unavailable';

  @override
  String get copyVersionLabel => 'Copy version';

  @override
  String get versionCopiedMessage => 'Version copied';

  @override
  String get reportBugTitle => 'Report a bug';

  @override
  String get reportBugSubtitle =>
      'Open GitHub Issues to report a bug or share feedback';

  @override
  String get reportBugAction => 'Open feedback page';

  @override
  String get feedbackOpenFailure => 'Could not open the feedback page';

  @override
  String get panelCurrentBookFallback => 'No book opened';

  @override
  String get exitMessage => 'Quit reader';

  @override
  String get modeToggleKeyLabel => 'Press M';

  @override
  String sliderPercent(Object value) {
    return '$value%';
  }
}
