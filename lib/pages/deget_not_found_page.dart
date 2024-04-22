import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class DebgetNotFoundPage extends StatelessWidget {
  const DebgetNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AdwScaffold(
      actions: AdwActions().windowManager,
      start: [BackButton()],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'quickemu was not found in your PATH',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Please install it and try again.',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                ),
                text: 'See ',
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(
                          Uri.parse(
                              'https://github.com/quickemu-project/quickemu'),
                        );
                      },
                    text: 'github.com/quickemu-project/quickemu',
                    style: const TextStyle(color: Colors.blue),
                  ),
                  const TextSpan(text: ' for more information'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
