import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:quickgui_adw/widgets/about_window.dart';

import '../settings.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdwComboRow(
          choices: ThemeMode.values.map((e) => e.name).toList(),
          title: 'Theme mode',
          selectedIndex: ThemeMode.values.indexOf(settings.themeMode),
          onSelected: (val) => settings.setThemeMode(ThemeMode.values[val]),
        ),
        AdwButton.flat(
          padding: AdwButton.defaultButtonPadding.copyWith(
            top: 10,
            bottom: 10,
          ),
          onPressed: () => showDialog<Widget>(
            context: context,
            builder: (ctx) => const AppAboutWindow(),
          ),
          child: const Text('About', style: TextStyle(fontSize: 15)),
        ),
      ],
    );
  }
}
