import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart' deferred as app_localizations;
// import 'package:intl/intl_standalone.dart';
import 'package:wonders/common_libs.dart';

class LocaleLogic {
  final Locale _defaultLocal = Locale('en');

  AppLocalizations? _strings;
  AppLocalizations get strings => _strings!;
  bool get isLoaded => _strings != null;
  bool get isEnglish => strings.localeName == 'en';

  Future<void> load() async {
    await app_localizations.loadLibrary();
    Locale locale = _defaultLocal;
    final localeCode = settingsLogic.currentLocale.value ?? '';
    locale = Locale(localeCode.split('_')[0]);
    if (kDebugMode) {
      // locale = Locale('zh'); // uncomment to test chinese
    }
    if (app_localizations.AppLocalizations.supportedLocales.contains(locale) == false) {
      locale = _defaultLocal;
    }

    settingsLogic.currentLocale.value = locale.languageCode;
    _strings = await app_localizations.AppLocalizations.delegate.load(locale);
  }

  Future<void> loadIfChanged(Locale locale) async {
    await app_localizations.loadLibrary();
    bool didChange = _strings?.localeName != locale.languageCode;
    if (didChange && app_localizations.AppLocalizations.supportedLocales.contains(locale)) {
      _strings = await app_localizations.AppLocalizations.delegate.load(locale);
    }
  }
}
