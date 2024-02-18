import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

import '../controllers/download_controller.dart';
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
  _DownloaderState createState() => _DownloaderState();
}

class _DownloaderState extends State<Downloader> {
  final notificationController = NotificationController();
  late DownloadController controller;
  bool _downloadFinished = false;

  @override
  void initState() {
    super.initState();
    controller = DownloadController(
        operatingSystem: widget.operatingSystem,
        version: widget.version,
        option: widget.option);
    controller.start().then((exitCode) {
      setState(() {
        _downloadFinished = true;
      });
      _showNotification(cancelled: exitCode.isNegative);
    });
  }

  @override
  void dispose() {
    controller.stop();
    super.dispose();
  }

  _showNotification({required bool cancelled}) {
    if (cancelled) {
      notificationController.notify(
        context.t('Download cancelled'),
        body: context.t('Download of {0} has been canceled.',
            args: [widget.operatingSystem.name]),
      );
    } else {
      notificationController.notify(
        context.t('Download complete'),
        body: context.t(
          'Download of {0} has completed.',
          args: [widget.operatingSystem.name],
        ),
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
            child: StreamBuilder(
              stream: controller.progressStream,
              builder: (context, AsyncSnapshot<double> snapshot) {
                var data = !snapshot.hasData ||
                        widget.option!.downloader != 'wget' ||
                        widget.option!.downloader != 'aria2c'
                    ? null
                    : snapshot.data;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DownloadLabel(
                      downloadFinished: _downloadFinished,
                      data: snapshot.hasData ? snapshot.data : null,
                      downloader: widget.option!.downloader,
                    ),
                    DownloadProgressBar(
                      downloadFinished: _downloadFinished,
                      data: snapshot.hasData ? data : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: Text(context.t('Target folder : {0}',
                          args: [Directory.current.path])),
                    ),
                  ],
                );
              },
            ),
          ),
          CancelDismissButton(
            onCancel: () => controller.stop(),
            downloadFinished: _downloadFinished,
          ),
        ],
      ),
    );
  }
}
