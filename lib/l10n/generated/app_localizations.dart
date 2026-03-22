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
  /// **'Press M'**
  String get triggerKeyboardLong;

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

  /// No description provided for @fontScaleLabel.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontScaleLabel;

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

  /// No description provided for @copyVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy version'**
  String get copyVersionLabel;

  /// No description provided for @versionCopiedMessage.
  ///
  /// In en, this message translates to:
  /// **'Version copied'**
  String get versionCopiedMessage;

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

  /// No description provided for @sliderPercent.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String sliderPercent(Object value);
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
