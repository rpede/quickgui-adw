import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:quickgui_adw/widgets/about_window.dart';
import 'package:quickgui_adw/widgets/preferences_window.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdwButton.flat(
          padding: AdwButton.defaultButtonPadding.copyWith(
            top: 10,
            bottom: 10,
          ),
          onPressed: () => showDialog<Widget>(
            context: context,
            builder: (ctx) => const PreferencesWindow(),
          ),
          child: const Text('Preferences', style: TextStyle(fontSize: 15)),
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
