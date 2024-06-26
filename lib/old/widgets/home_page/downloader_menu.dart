import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

import '../../../settings.dart';
import 'home_page_button_group.dart';

class DownloaderMenu extends StatefulWidget {
  const DownloaderMenu({super.key});

  @override
  State<DownloaderMenu> createState() => _DownloaderMenuState();
}

class _DownloaderMenuState extends State<DownloaderMenu> {
  void _onTapPath() async {
    var folder = await FilePicker.platform
        .getDirectoryPath(dialogTitle: "Pick a folder");
    if (folder != null) {
      setState(() {
        Directory.current = folder;
      });
      if (mounted) context.read<Settings>().setWorkingDirectory(folder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.primary,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${context.t('Directory where the machines are stored')}:",
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text.rich(
                    TextSpan(
                      recognizer: TapGestureRecognizer()..onTap = _onTapPath,
                      text: Directory.current.path,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              thickness: 2,
            ),
            const Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: HomePageButtonGroup(),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
