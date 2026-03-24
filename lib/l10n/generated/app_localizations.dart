import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'CheatReader'**
  String get appTitle;

  /// No description provided for @demoTitle.
  ///
  /// In en, this message translates to:
  /// **'Demo Text'**
  String get demoTitle;

  /// No description provided for @emptyText.
  ///
  /// In en, this message translates to:
  /// **'(Empty text)'**
  String get emptyText;

  /// No description provided for @untitledText.
  ///
  /// In en, this message translates to:
  /// **'Untitled text'**
  String get untitledText;

  /// No description provided for @demoContent.
  ///
  /// In en, this message translates to:
  /// **'After finishing work messages, the reader should still be waiting on the same line.\nIt does not need to take over the center of the desktop, and it does not need to remind you that it exists.\nA small readable area in your peripheral vision is enough to keep moving forward.\nSingle-line mode is for hiding sentences at the edge of the screen, while multi-line mode is for brief focused reading.\nScrolling down moves forward by one line, and scrolling up moves back by one line.\nArrow keys should behave exactly the same way.\nPressing PageDown should move the content forward by the visible reading range.\nPageUp should move back toward the top of the previous reading view.\nThe right-click menu carries all immediate settings, with no toolbar and no status bar.\nThe font can be enlarged a little, opacity can be lowered a little, and always-on-top can be switched instantly.\nIf the platform supports a frameless window, let it feel like a floating note.\nIf it does not, at least keep it simple and stable.\nThe first step of this project is not a full library manager, sync service, or rich-format parser.\nIt just aims to be a reader that is light, fast, and easy to ignore.\nWhen you pause, the current position should always be preserved.\nWhen you return, one more scroll should let you continue from the same rhythm.'**
  String get demoContent;

  /// No description provided for @importNoFiles.
  ///
  /// In en, this message translates to:
  /// **'No importable ebook files found'**
  String get importNoFiles;

  /// No description provided for @importOpenFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not open this ebook file'**
  String get importOpenFailure;

  /// No description provided for @importFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not import this ebook file'**
  String get importFailure;

  /// No description provided for @importUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Only txt / epub / html / md / fb2 / docx / pdf are supported'**
  String get importUnsupportedFormat;

  /// No description provided for @dropPrompt.
  ///
  /// In en, this message translates to:
  /// **'Drop txt / epub / html / md / fb2 / docx / pdf here to start reading'**
  String get dropPrompt;

  /// No description provided for @controlPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'CheatReader Control Panel'**
  String get controlPanelTitle;

  /// No description provided for @importEbook.
  ///
  /// In en, this message translates to:
  /// **'Import ebook'**
  String get importEbook;

  /// No description provided for @quitReader.
  ///
  /// In en, this message translates to:
  /// **'Quit reader'**
  String get quitReader;

  /// No description provided for @bookshelfTitle.
  ///
  /// In en, this message translates to:
  /// **'Bookshelf'**
  String get bookshelfTitle;

  /// No description provided for @bookshelfEmpty.
  ///
  /// In en, this message translates to:
  /// **'No imported books yet. You can drag files into the window or use the import button above.'**
  String get bookshelfEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reading Settings'**
  String get settingsTitle;

  /// No description provided for @modeToggleMethod.
  ///
  /// In en, this message translates to:
  /// **'Display mode switch trigger'**
  String get modeToggleMethod;

  /// No description provided for @triggerDoubleClick.
  ///
  /// In en, this message translates to:
  /// **'Double click'**
  String get triggerDoubleClick;

  /// No description provided for @triggerMiddleClick.
  ///
  /// In en, this message translates to:
  /// **'Middle click'**
  String get triggerMiddleClick;

  /// No description provided for @triggerKeyboard.
  ///
  /// In en, this message translates to:
  /// **'Shortcut'**
  String get triggerKeyboard;

  /// No description provided for @triggerDoubleClickLong.
  ///
  /// In en, this message translates to:
  /// **'Double-click the reader area'**
  String get triggerDoubleClickLong;

  /// No description provided for @triggerMiddleClickLong.
  ///
  /// In en, this message translates to:
  /// **'Middle-click the reader area'**
  String get triggerMiddleClickLong;

  /// No description provided for @triggerKeyboardLong.
  ///
  /// In en, this message translates to:
  /// **'Press {shortcut}'**
  String triggerKeyboardLong(Object shortcut);

  /// No description provided for @modeSingleLine.
  ///
  /// In en, this message translates to:
  /// **'single-line'**
  String get modeSingleLine;

  /// No description provided for @modeMultiLine.
  ///
  /// In en, this message translates to:
  /// **'multi-line'**
  String get modeMultiLine;

  /// No description provided for @currentModeSummary.
  ///
  /// In en, this message translates to:
  /// **'Current mode: {mode}. Trigger: {trigger}'**
  String currentModeSummary(Object mode, Object trigger);

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageZhHans.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageZhHans;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @alwaysOnTopTitle.
  ///
  /// In en, this message translates to:
  /// **'Always on top'**
  String get alwaysOnTopTitle;

  /// No description provided for @alwaysOnTopSupported.
  ///
  /// In en, this message translates to:
  /// **'Keep the reader floating above other windows'**
  String get alwaysOnTopSupported;

  /// No description provided for @alwaysOnTopUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This platform does not support it right now'**
  String get alwaysOnTopUnsupported;

  /// No description provided for @transparentModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Transparent mode'**
  String get transparentModeTitle;

  /// No description provided for @transparentModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove every background tint and keep text only'**
  String get transparentModeSubtitle;

  /// No description provided for @fontTitle.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get fontTitle;

  /// No description provided for @fontDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get fontDefault;

  /// No description provided for @fontSerif.
  ///
  /// In en, this message translates to:
  /// **'Serif'**
  String get fontSerif;

  /// No description provided for @fontMonospace.
  ///
  /// In en, this message translates to:
  /// **'Monospace'**
  String get fontMonospace;

  /// No description provided for @fontColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Text color'**
  String get fontColorTitle;

  /// No description provided for @fontColorAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get fontColorAuto;

  /// No description provided for @fontColorCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get fontColorCustom;

  /// No description provided for @fontColorAutoHint.
  ///
  /// In en, this message translates to:
  /// **'Automatic mode keeps choosing a safer text color for the current reader background. Transparent mode also adds a readability shadow.'**
  String get fontColorAutoHint;

  /// No description provided for @fontColorCustomHint.
  ///
  /// In en, this message translates to:
  /// **'Custom mode overrides automatic text color selection. Transparent mode still keeps the readability shadow.'**
  String get fontColorCustomHint;

  /// No description provided for @fontColorPreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get fontColorPreviewLabel;

  /// No description provided for @fontColorPreviewSample.
  ///
  /// In en, this message translates to:
  /// **'Reader preview'**
  String get fontColorPreviewSample;

  /// No description provided for @fontColorPresetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Quick colors'**
  String get fontColorPresetsLabel;

  /// No description provided for @fontColorHueLabel.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get fontColorHueLabel;

  /// No description provided for @fontColorSaturationLabel.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get fontColorSaturationLabel;

  /// No description provided for @fontColorLightnessLabel.
  ///
  /// In en, this message translates to:
  /// **'Lightness'**
  String get fontColorLightnessLabel;

  /// No description provided for @fontScaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontScaleLabel;

  /// No description provided for @lineSpacingLabel.
  ///
  /// In en, this message translates to:
  /// **'Line spacing'**
  String get lineSpacingLabel;

  /// No description provided for @readingWidthLabel.
  ///
  /// In en, this message translates to:
  /// **'Reading width'**
  String get readingWidthLabel;

  /// No description provided for @windowOpacityLabel.
  ///
  /// In en, this message translates to:
  /// **'Background opacity'**
  String get windowOpacityLabel;

  /// No description provided for @transparentModeOverridesOpacity.
  ///
  /// In en, this message translates to:
  /// **'Controlled by transparent mode'**
  String get transparentModeOverridesOpacity;

  /// No description provided for @shortcutConflictMessage.
  ///
  /// In en, this message translates to:
  /// **'This shortcut is already assigned to another action'**
  String get shortcutConflictMessage;

  /// No description provided for @positionLabel.
  ///
  /// In en, this message translates to:
  /// **'Position {line}'**
  String positionLabel(Object line);

  /// No description provided for @fileMayBeInvalid.
  ///
  /// In en, this message translates to:
  /// **'File may no longer be available'**
  String get fileMayBeInvalid;

  /// No description provided for @removeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeTooltip;

  /// No description provided for @sectionSimpleBookshelf.
  ///
  /// In en, this message translates to:
  /// **'Bookshelf'**
  String get sectionSimpleBookshelf;

  /// No description provided for @sectionReadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Reading Settings'**
  String get sectionReadingSettings;

  /// No description provided for @sectionKeyboardControls.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Controls'**
  String get sectionKeyboardControls;

  /// No description provided for @sectionAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get sectionAboutApp;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get appVersionLabel;

  /// No description provided for @appVersionLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get appVersionLoading;

  /// No description provided for @appVersionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get appVersionUnavailable;

  /// No description provided for @checkLatestVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Check latest version'**
  String get checkLatestVersionLabel;

  /// No description provided for @alreadyLatestVersionMessage.
  ///
  /// In en, this message translates to:
  /// **'You already have the latest version'**
  String get alreadyLatestVersionMessage;

  /// No description provided for @latestVersionOpenedFallback.
  ///
  /// In en, this message translates to:
  /// **'Automatic checking is unavailable right now. The Releases page has been opened for you'**
  String get latestVersionOpenedFallback;

  /// No description provided for @latestVersionReadCurrentFailed.
  ///
  /// In en, this message translates to:
  /// **'The current app version could not be read. The Releases page has been opened for you'**
  String get latestVersionReadCurrentFailed;

  /// No description provided for @latestVersionCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check the latest version right now'**
  String get latestVersionCheckFailed;

  /// No description provided for @latestVersionOpenFailure.
  ///
  /// In en, this message translates to:
  /// **'A newer version was found, but the Releases page could not be opened'**
  String get latestVersionOpenFailure;

  /// No description provided for @reportBugTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get reportBugTitle;

  /// No description provided for @reportBugSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open GitHub Issues to report a bug or share feedback'**
  String get reportBugSubtitle;

  /// No description provided for @reportBugAction.
  ///
  /// In en, this message translates to:
  /// **'Open feedback page'**
  String get reportBugAction;

  /// No description provided for @feedbackOpenFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not open the feedback page'**
  String get feedbackOpenFailure;

  /// No description provided for @panelCurrentBookFallback.
  ///
  /// In en, this message translates to:
  /// **'No book opened'**
  String get panelCurrentBookFallback;

  /// No description provided for @exitMessage.
  ///
  /// In en, this message translates to:
  /// **'Quit reader'**
  String get exitMessage;

  /// No description provided for @modeToggleKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Press M'**
  String get modeToggleKeyLabel;

  /// No description provided for @bossKeyHideNow.
  ///
  /// In en, this message translates to:
  /// **'Hide now'**
  String get bossKeyHideNow;

  /// No description provided for @shortcutNextLine.
  ///
  /// In en, this message translates to:
  /// **'Next line'**
  String get shortcutNextLine;

  /// No description provided for @shortcutPreviousLine.
  ///
  /// In en, this message translates to:
  /// **'Previous line'**
  String get shortcutPreviousLine;

  /// No description provided for @shortcutNextPage.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get shortcutNextPage;

  /// No description provided for @shortcutPreviousPage.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get shortcutPreviousPage;

  /// No description provided for @shortcutToggleMode.
  ///
  /// In en, this message translates to:
  /// **'Toggle mode'**
  String get shortcutToggleMode;

  /// No description provided for @shortcutBossKey.
  ///
  /// In en, this message translates to:
  /// **'Boss key'**
  String get shortcutBossKey;

  /// No description provided for @shortcutKeyArrowDown.
  ///
  /// In en, this message translates to:
  /// **'Arrow Down'**
  String get shortcutKeyArrowDown;

  /// No description provided for @shortcutKeyArrowUp.
  ///
  /// In en, this message translates to:
  /// **'Arrow Up'**
  String get shortcutKeyArrowUp;

  /// No description provided for @shortcutKeyPageDown.
  ///
  /// In en, this message translates to:
  /// **'Page Down'**
  String get shortcutKeyPageDown;

  /// No description provided for @shortcutKeyPageUp.
  ///
  /// In en, this message translates to:
  /// **'Page Up'**
  String get shortcutKeyPageUp;

  /// No description provided for @shortcutKeySpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get shortcutKeySpace;

  /// No description provided for @shortcutKeyShiftSpace.
  ///
  /// In en, this message translates to:
  /// **'Shift + Space'**
  String get shortcutKeyShiftSpace;

  /// No description provided for @sliderPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String sliderPercent(Object value);

  /// No description provided for @sliderMultiplier.
  ///
  /// In en, this message translates to:
  /// **'{value}x'**
  String sliderMultiplier(Object value);

  /// No description provided for @sliderDegrees.
  ///
  /// In en, this message translates to:
  /// **'{value}°'**
  String sliderDegrees(Object value);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
