import 'package:flutter/material.dart';

class DownloadProgressBar extends StatelessWidget {
  const DownloadProgressBar({
    super.key,
    required this.downloadFinished,
    required this.data,
  });

  final bool downloadFinished;
  final double? data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 200,
        child: LinearProgressIndicator(
          value: downloadFinished ? 1 : data,
        ),
      ),
    );
  }
}
