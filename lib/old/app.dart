import 'package:adwaita/adwaita.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import '../mixins/app_version.dart';
import 'pages/deget_not_found_page.dart';
import 'pages/main_page.dart';
import '../settings.dart';
import '../supported_locales.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Locale? _localeListResolution(locales, supportedLocales) {
    if (locales != null) {
      for (var locale in locales) {
        var supportedLocale = supportedLocales.where((element) =>
            element.languageCode == locale.languageCode &&
            element.countryCode == locale.countryCode);
        if (supportedLocale.isNotEmpty) {
          return supportedLocale.first;
        }
        supportedLocale = supportedLocales
            .where((element) => element.languageCode == locale.languageCode);
        if (supportedLocale.isNotEmpty) {
          return supportedLocale.first;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();

    final languageCode = settings.locale!.split("_")[0];
    final countryCode =
        ((settings.locale != null) && (settings.locale!.contains("_")))
            ? settings.locale!.split("_")[1]
            : null;

    return MaterialApp(
      builder: (context, child) {
        final virtualWindowFrame = VirtualWindowFrameInit();

        return virtualWindowFrame(context, child);
      },
      theme: AdwaitaThemeData.light(),
      darkTheme: AdwaitaThemeData.dark(),
      // theme: ThemeData(primarySwatch: Colors.pink),
      // darkTheme: ThemeData.dark(),
      themeMode: settings.themeMode,
      debugShowCheckedModeBanner: false,
      home: AppVersion.packageInfo == null
          ? const DebgetNotFoundPage()
          : const MainPage(),
      supportedLocales: supportedLocales.map((s) => s.contains("_")
          ? Locale(s.split("_")[0], s.split("_")[1])
          : Locale(s)),
      localizationsDelegates: [
        GettextLocalizationsDelegate(),
        ...GlobalMaterialLocalizations.delegates,
        GlobalWidgetsLocalizations.delegate,
      ],
      locale: Locale(languageCode, countryCode),
      localeListResolutionCallback: _localeListResolution,
    );
  }
}
