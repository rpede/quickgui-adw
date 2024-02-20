import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

import '../bloc/download_cubit.dart';
import '../bloc/download_state.dart';
import '../controllers/notification_controller.dart';
import '../model/operating_system.dart';
import '../model/option.dart';
import '../model/version.dart';
import '../widgets/downloader/cancel_dismiss_button.dart';
import '../widgets/downloader/download_label.dart';
import '../widgets/downloader/download_progress_bar.dart';

class Downloader extends StatefulWidget {
  const Downloader({
    super.key,
    required this.operatingSystem,
    required this.version,
    this.option,
  });

  final OperatingSystem operatingSystem;
  final Version version;
  final Option? option;

  @override
  State<Downloader> createState() => _DownloaderState();
}

class _DownloaderState extends State<Downloader> {
  final notificationController = NotificationController();

  @override
  void initState() {
    super.initState();
    context
        .read<DownloadCubit>()
        .start(widget.operatingSystem, widget.version, widget.option)
        .then((completed) => _showNotification(completed: completed));
  }

  _showNotification({required bool completed}) {
    if (completed) {
      notificationController.notify(
        context.t('Download complete'),
        body: context.t(
          'Download of {0} has completed.',
          args: [widget.operatingSystem.name],
        ),
      );
    } else {
      notificationController.notify(
        context.t('Download cancelled'),
        body: context.t('Download of {0} has been canceled.',
            args: [widget.operatingSystem.name]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.t('Downloading {0}', args: [
            '${widget.operatingSystem.name} ${widget.version.version} ${widget.option?.option ?? ''}'
          ]),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<DownloadCubit, DownloadState>(
              builder: (context, state) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final download in state) ...[
                      DownloadLabel(
                        downloadFinished: download.success,
                        data: download.progress,
                        downloader: widget.option!.downloader,
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
