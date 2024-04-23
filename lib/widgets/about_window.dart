import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:url_launcher/url_launcher.dart';

class AppAboutWindow extends StatelessWidget {
  const AppAboutWindow({super.key});

  final developers = const {
    'Rasmus Pedersen': 'rpede',
    'Quickemu Project': 'quickemu-project',
  };

  @override
  Widget build(BuildContext context) {
    return AdwAboutWindow(
      appIcon: Image.asset('assets/images/logo_pink.png'),
      credits: [
        AdwPreferencesGroup.creditsBuilder(
          title: 'Developers',
          itemCount: developers.length,
          itemBuilder: (_, index) => AdwActionRow(
            title: developers.keys.elementAt(index),
            onActivated: () => launchUrl(
              Uri.parse(
                'https://github.com/${developers.values.elementAt(index)}',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
