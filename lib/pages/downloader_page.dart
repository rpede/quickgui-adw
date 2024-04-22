import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:provider/provider.dart';

import '../bloc/download_cubit.dart';
import '../widgets/home_page/downloader_menu.dart';
import '../widgets/home_page/logo.dart';

class DownloaderPage extends StatefulWidget {
  const DownloaderPage({super.key});

  @override
  State<DownloaderPage> createState() => _DownloaderPageState();
}

class _DownloaderPageState extends State<DownloaderPage> {
  @override
  void initState() {
    super.initState();
    context.read<DownloadCubit>().loadChoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('Downloader')),
      ),
      body: const Column(
        children: [
          Logo(),
          DownloaderMenu(),
        ],
      ),
    );
  }
}
