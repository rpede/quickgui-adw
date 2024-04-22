import 'dart:io';

import 'package:desktop_notifications/desktop_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';
import 'package:quickgui_adw/widgets/adw_back_button.dart';

import '../bloc/download_cubit.dart';
import '../bloc/download_state.dart';
import '../model/download_description.dart';
import '../model/operating_system.dart';
import '../model/option.dart';
import '../model/version.dart';
import '../widgets/downloader/cancel_dismiss_button.dart';
import '../widgets/downloader/download_label.dart';
import '../widgets/downloader/download_progress_bar.dart';

class Downloader extends StatefulWidget {
  const Downloader(this.description, {super.key});

  final DownloadDescription description;

  @override
  State<Downloader> createState() => _DownloaderState();
}

class _DownloaderState extends State<Downloader> {
  final notifications = NotificationsClient();

  OperatingSystem get operatingSystem => widget.description.operatingSystem;
  Version get version => widget.description.version;
  Option? get option => widget.description.option;

  @override
  void initState() {
    super.initState();
    context
        .read<DownloadCubit>()
        .start(widget.description)
        .then((completed) => _showNotification(completed: completed));
  }

  _showNotification({required bool completed}) {
    notifications.notify(
      completed
          ? context.t('Download complete')
          : context.t('Download cancelled'),
      body: completed
          ? context.t(
              'Download of {0} has completed.',
              args: [operatingSystem.name],
            )
          : context.t(
              'Download of {0} has been canceled.',
              args: [operatingSystem.name],
            ),
      appName: 'Quickgui',
      expireTimeoutMs: 10000, /* 10 seconds */
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdwScaffold(
      actions: AdwActions().windowManager,
      start: [AdwBackButton()],
      title: Text(
        context.t('Downloading {0}', args: [
          '${operatingSystem.name} ${version.version} ${option?.option ?? ''}'
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<DownloadCubit, DownloaderState>(
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final download in state.downloads) ...[
                      DownloadLabel(
                        downloadFinished: download.success,
                        data: download.progress,
                        downloader: option!.downloader,
                      ),
                      DownloadProgressBar(
                        downloadFinished: download.success,
                        data: download.progress,
                      ),
                      CancelDismissButton(
                        onCancel: () => {},
                        downloadFinished: download.success,
                      ),
                      const Divider(),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Text(
                        context.t('Target folder : {0}',
                            args: [Directory.current.path]),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
