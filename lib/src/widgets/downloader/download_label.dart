import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

class DownloadLabel extends StatelessWidget {
  const DownloadLabel(
      {super.key,
      required this.downloadFinished,
      required this.data,
      required this.downloader});

  final bool downloadFinished;
  final double? data;
  final String downloader;

  String _downloadStatus(BuildContext context) {
    if (downloadFinished) return context.t('Download finished.');
    if (data == null) return context.t('Waiting for download to start');
    if (downloader == 'zsync') {
      return context.t("Downloading (no progress available)...");
    }
    if (downloader == 'wget' || downloader == 'aria2c') {
      return context.t('Downloading... {0}%', args: [(data! * 100).toInt()]);
    }
    return context.t('{0} Mbs downloaded', args: [data!]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(_downloadStatus(context))
    );
  }
}
