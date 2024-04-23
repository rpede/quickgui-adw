import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MissingQuickemu extends StatelessWidget {
  const MissingQuickemu({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '"quickemu" was not found in your PATH',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please install it and try again.',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
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
                const TextSpan(text: ' for more information.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
