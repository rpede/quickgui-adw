import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:provider/provider.dart';

import '../mixins/app_version.dart';
import '../settings.dart';
import '../supported_locales.dart';

class LeftMenu extends StatelessWidget {
  const LeftMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();

    var currentLocale = settings.locale;
    if (!supportedLocales.contains(currentLocale)) {
      currentLocale = currentLocale?.split("_")[0];
      if (!supportedLocales.contains(currentLocale)) {
        currentLocale = "en";
      }
    }
    var version = AppVersion.packageInfo!.version;
    return Consumer<Settings>(
      builder: (context, appSettings, _) {
        return Column(
          children: [
            ListTile(
              title: Text("quickgui $version",
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(context.t('Use dark mode')),
                  Expanded(
                    child: Container(),
                  ),
                  Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) {
                      appSettings.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(context.t('Language')),
                  Expanded(
                    child: Container(),
                  ),
                  DropdownButton<String>(
                    value: currentLocale,
                    items: supportedLocales
                        .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) =>
                        context.read<Settings>().setLocale(value),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
