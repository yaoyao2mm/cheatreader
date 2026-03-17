import 'dart:ui';

import '../l10n/generated/app_localizations.dart';
import 'reader_settings.dart';

Locale? materialLocaleForLanguageMode(ReaderLanguageMode mode) {
  return switch (mode) {
    ReaderLanguageMode.system => null,
    ReaderLanguageMode.simplifiedChinese => const Locale('zh'),
    ReaderLanguageMode.english => const Locale('en'),
  };
}

Locale effectiveLocaleForLanguageMode(ReaderLanguageMode mode) {
  final locale = switch (mode) {
    ReaderLanguageMode.system => PlatformDispatcher.instance.locale,
    ReaderLanguageMode.simplifiedChinese => const Locale('zh'),
    ReaderLanguageMode.english => const Locale('en'),
  };

  if (locale.languageCode.toLowerCase().startsWith('zh')) {
    return const Locale('zh');
  }
  return const Locale('en');
}

AppLocalizations stringsForSettings(ReaderSettings settings) {
  return lookupAppLocalizations(
    effectiveLocaleForLanguageMode(settings.languageMode),
  );
}

AppLocalizations stringsForLanguageMode(ReaderLanguageMode mode) {
  return lookupAppLocalizations(effectiveLocaleForLanguageMode(mode));
}
