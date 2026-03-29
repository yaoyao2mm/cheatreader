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
      'Only txt / epub / html / md / fb2 / docx / pdf are supported';

  @override
  String get dropPrompt =>
      'Drop txt / epub / html / md / fb2 / docx / pdf here to start reading';

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
  String triggerKeyboardLong(Object shortcut) {
    return 'Press $shortcut';
  }

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
  String get transparentTextShadowTitle => 'Text outline in transparent mode';

  @override
  String get transparentTextShadowSubtitle =>
      'Add a readability halo around letters when the reader has no background';

  @override
  String get readingAnimationTitle => 'Reading transition animation';

  @override
  String get readingAnimationSubtitle =>
      'Off by default. When enabled, use only a slight slide to soften line changes without trailing ghosts';

  @override
  String get fontTitle => 'Font';

  @override
  String get fontDefault => 'Default';

  @override
  String get fontSerif => 'Serif';

  @override
  String get fontMonospace => 'Monospace';

  @override
  String get fontCustom => 'Custom';

  @override
  String get customFontChooseAction => 'Choose font';

  @override
  String get customFontReplaceAction => 'Replace font';

  @override
  String get customFontRemoveAction => 'Remove font';

  @override
  String get customFontPickFailure => 'Could not open the font picker';

  @override
  String get customFontLoadFailure => 'Could not load this font file';

  @override
  String get fontColorTitle => 'Text color';

  @override
  String get fontColorAuto => 'Automatic';

  @override
  String get fontColorCustom => 'Custom';

  @override
  String get fontColorAutoHint =>
      'Automatic mode keeps choosing a safer text color for the current reader background. Transparent mode also adds a readability shadow.';

  @override
  String get fontColorCustomHint =>
      'Custom mode overrides automatic text color selection. Transparent mode still keeps the readability shadow.';

  @override
  String get fontColorPreviewLabel => 'Preview';

  @override
  String get fontColorPreviewSample => 'Reader preview';

  @override
  String get fontColorPresetsLabel => 'Quick colors';

  @override
  String get fontColorHueLabel => 'Hue';

  @override
  String get fontColorSaturationLabel => 'Saturation';

  @override
  String get fontColorLightnessLabel => 'Lightness';

  @override
  String get fontScaleLabel => 'Font size';

  @override
  String get lineSpacingLabel => 'Line spacing';

  @override
  String get readingWidthLabel => 'Reading width';

  @override
  String get windowOpacityLabel => 'Background opacity';

  @override
  String get transparentModeOverridesOpacity =>
      'Controlled by transparent mode';

  @override
  String get shortcutConflictMessage =>
      'This shortcut is already assigned to another action';

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
  String get sectionReadingPosition => 'Reading Position';

  @override
  String get readingPositionLineStat => 'Line';

  @override
  String get readingPositionPageStat => 'Page';

  @override
  String get readingPositionProgressStat => 'Progress';

  @override
  String get sectionReadingSettings => 'Reading Settings';

  @override
  String get sectionKeyboardControls => 'Keyboard Controls';

  @override
  String get sectionAboutApp => 'About';

  @override
  String currentLineSummary(Object current, Object total) {
    return 'Line $current / $total';
  }

  @override
  String currentPageSummary(Object current, Object total) {
    return 'Page $current / $total';
  }

  @override
  String currentProgressSummary(Object percent) {
    return 'Progress $percent%';
  }

  @override
  String get jumpToLineLabel => 'Jump to line';

  @override
  String jumpToLineHint(Object max) {
    return '1 to $max';
  }

  @override
  String get jumpToPageLabel => 'Jump to page';

  @override
  String jumpToPageHint(Object max) {
    return '1 to $max';
  }

  @override
  String get jumpToPercentLabel => 'Jump to percent';

  @override
  String get jumpToPercentHint => '0 to 100';

  @override
  String get jumpAction => 'Go';

  @override
  String get jumpInputInvalid => 'Enter a whole number';

  @override
  String get searchLabel => 'Search';

  @override
  String get searchHint => 'Find text';

  @override
  String get searchPreviousAction => 'Previous';

  @override
  String get searchNextAction => 'Next';

  @override
  String get searchEmptyQuery => 'Enter text to search';

  @override
  String get searchNotFound => 'No matching text found';

  @override
  String jumpLineOutOfRange(Object max) {
    return 'Line must be between 1 and $max';
  }

  @override
  String jumpPageOutOfRange(Object max) {
    return 'Page must be between 1 and $max';
  }

  @override
  String get jumpPercentOutOfRange => 'Percent must be between 0 and 100';

  @override
  String get appVersionLabel => 'Version';

  @override
  String get appVersionLoading => 'Loading...';

  @override
  String get appVersionUnavailable => 'Unavailable';

  @override
  String get checkLatestVersionLabel => 'Check latest version';

  @override
  String get alreadyLatestVersionMessage =>
      'You already have the latest version';

  @override
  String get latestVersionOpenedFallback =>
      'Automatic checking is unavailable right now. The Releases page has been opened for you';

  @override
  String get latestVersionReadCurrentFailed =>
      'The current app version could not be read. The Releases page has been opened for you';

  @override
  String get latestVersionCheckFailed =>
      'Could not check the latest version right now';

  @override
  String get latestVersionOpenFailure =>
      'A newer version was found, but the Releases page could not be opened';

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
  String get bossKeyHideNow => 'Hide now';

  @override
  String get shortcutNextLine => 'Next line';

  @override
  String get shortcutPreviousLine => 'Previous line';

  @override
  String get shortcutNextPage => 'Next page';

  @override
  String get shortcutPreviousPage => 'Previous page';

  @override
  String get shortcutToggleMode => 'Toggle mode';

  @override
  String get shortcutBossKey => 'Boss key';

  @override
  String get shortcutKeyArrowDown => 'Arrow Down';

  @override
  String get shortcutKeyArrowUp => 'Arrow Up';

  @override
  String get shortcutKeyPageDown => 'Page Down';

  @override
  String get shortcutKeyPageUp => 'Page Up';

  @override
  String get shortcutKeySpace => 'Space';

  @override
  String get shortcutKeyShiftSpace => 'Shift + Space';

  @override
  String sliderPercent(Object value) {
    return '$value%';
  }

  @override
  String sliderMultiplier(Object value) {
    return '${value}x';
  }

  @override
  String sliderDegrees(Object value) {
    return '$value°';
  }
}
