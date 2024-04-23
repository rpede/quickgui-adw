import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';

import '../widgets/home_page/logo.dart';
import '../widgets/home_page/main_menu.dart';
import '../widgets/left_menu.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // TODO fix title
    // setWindowTitle(
    //     context.t('Quickgui : a Flutter frontend for Quickget and Quickemu'));
  }

  @override
  Widget build(BuildContext context) {
    return AdwScaffold(
      actions: AdwActions().windowManager,
      title: Text(context.t('Main menu')),
      end: [GtkPopupMenu(body: LeftMenu())],
      // drawer: const LeftMenu(),
      body: const Column(
        children: [
          Logo(),
          MainMenu(),
        ],
      ),
    );
  }
}
