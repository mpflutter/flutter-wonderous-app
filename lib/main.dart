import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/artifact_api_logic.dart';
import 'package:wonders/logic/artifact_api_logic.dart' deferred as artifact_api_logic;
import 'package:wonders/logic/artifact_api_service.dart';
import 'package:wonders/logic/collectibles_logic.dart';
import 'package:wonders/logic/collectibles_logic.dart' deferred as collectibles_logic;
import 'package:wonders/logic/native_widget_service.dart';
import 'package:wonders/logic/locale_logic.dart';
import 'package:wonders/logic/locale_logic.dart' deferred as locale_logic;
import 'package:wonders/logic/timeline_logic.dart';
import 'package:wonders/logic/timeline_logic.dart' deferred as timeline_logic;
import 'package:wonders/logic/unsplash_logic.dart';
import 'package:wonders/logic/unsplash_logic.dart' deferred as unsplash_logic;
import 'package:wonders/logic/wonders_logic.dart';
import 'package:wonders/logic/wonders_logic.dart' deferred as wonders_logic;
import 'package:wonders/ui/common/app_shortcuts.dart';

import 'package:mpflutter_core/mpflutter_core.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  if (!kIsMPFlutter) {
    // Keep native splash screen up until app is finished bootstrapping
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
    GoRouter.optionURLReflectsImperativeAPIs = true;
  }

  await wonders_logic.loadLibrary();
  await unsplash_logic.loadLibrary();
  await timeline_logic.loadLibrary();
  await locale_logic.loadLibrary();
  await collectibles_logic.loadLibrary();
  await artifact_api_logic.loadLibrary();

  // Start app
  registerSingletons();

  if (kIsMPFlutter) {
    runMPApp(WondersApp());
  } else {
    runApp(WondersApp());
  }

  await appLogic.bootstrap();

  // Remove splash screen when bootstrap is complete
  if (!kIsMPFlutter) {
    FlutterNativeSplash.remove();
  }
}

/// Creates an app using the [MaterialApp.router] constructor and the global `appRouter`, an instance of [GoRouter].
class WondersApp extends StatelessWidget with GetItMixin {
  WondersApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final locale = watchX((SettingsLogic s) => s.currentLocale);
    return MaterialApp.router(
      routeInformationProvider: appRouter.routeInformationProvider,
      routeInformationParser: appRouter.routeInformationParser,
      locale: locale == null ? null : Locale(locale),
      debugShowCheckedModeBanner: false,
      routerDelegate: appRouter.routerDelegate,
      shortcuts: AppShortcuts.defaults,
      theme: ThemeData(fontFamily: $styles.text.body.fontFamily, useMaterial3: true),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // onNavigationNotification: (_) {
      //   return false;
      // },
    );
  }
}

/// Create singletons (logic and services) that can be shared across the app.
void registerSingletons() {
  // Top level app controller
  GetIt.I.registerLazySingleton<AppLogic>(() => AppLogic());
  // Wonders
  GetIt.I.registerLazySingleton<WondersLogic>(() => wonders_logic.WondersLogic());
  // Timeline / Events
  GetIt.I.registerLazySingleton<TimelineLogic>(() => timeline_logic.TimelineLogic());
  // Search
  GetIt.I.registerLazySingleton<ArtifactAPILogic>(() => artifact_api_logic.ArtifactAPILogic());
  GetIt.I.registerLazySingleton<ArtifactAPIService>(() => ArtifactAPIService());
  // Settings
  GetIt.I.registerLazySingleton<SettingsLogic>(() => SettingsLogic());
  // Unsplash
  GetIt.I.registerLazySingleton<UnsplashLogic>(() => unsplash_logic.UnsplashLogic());
  // Collectibles
  GetIt.I.registerLazySingleton<CollectiblesLogic>(() => collectibles_logic.CollectiblesLogic());
  // Localizations
  GetIt.I.registerLazySingleton<LocaleLogic>(() => locale_logic.LocaleLogic());
  // Home Widget Service
  GetIt.I.registerLazySingleton<NativeWidgetService>(() => NativeWidgetService());
}

/// Add syntax sugar for quickly accessing the main "logic" controllers in the app
/// We deliberately do not create shortcuts for services, to discourage their use directly in the view/widget layer.
AppLogic get appLogic => GetIt.I.get<AppLogic>();
WondersLogic get wondersLogic => GetIt.I.get<WondersLogic>();
TimelineLogic get timelineLogic => GetIt.I.get<TimelineLogic>();
SettingsLogic get settingsLogic => GetIt.I.get<SettingsLogic>();
UnsplashLogic get unsplashLogic => GetIt.I.get<UnsplashLogic>();
ArtifactAPILogic get artifactLogic => GetIt.I.get<ArtifactAPILogic>();
CollectiblesLogic get collectiblesLogic => GetIt.I.get<CollectiblesLogic>();
LocaleLogic get localeLogic => GetIt.I.get<LocaleLogic>();

/// Global helpers for readability
AppLocalizations get $strings => localeLogic.strings;
AppStyle get $styles => WondersAppScaffold.style;
