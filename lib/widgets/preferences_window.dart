import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:provider/provider.dart';

import '../settings.dart';

class PreferencesWindow extends StatelessWidget {
  const PreferencesWindow({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    return GtkDialog(
        constraints: const BoxConstraints(
          maxWidth: 360,
          minHeight: 350,
          maxHeight: 400,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        children: [
          AdwPreferencesGroup(children: [
            AdwComboRow(
              choices: ThemeMode.values.map((e) => e.name).toList(),
              title: 'Style',
              selectedIndex: ThemeMode.values.indexOf(settings.themeMode),
              onSelected: (val) => settings.setThemeMode(ThemeMode.values[val]),
            ),
            AdwActionRow(
              title: "Working directory",
              subtitle: settings.workingDirectory,
              onActivated: () async {
                String? result = await FilePicker.platform.getDirectoryPath();
                settings.setWorkingDirectory(result);
              },
            )
          ])
        ]);
  }
}
