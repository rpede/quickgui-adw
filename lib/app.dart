import 'package:adwaita/adwaita.dart';
import 'package:adwaita_icons/adwaita_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';
import 'package:quickgui_adw/widgets/vm_list.dart';
import 'package:window_manager/window_manager.dart';

import 'bloc/manager_cubit.dart';
import 'bloc/manager_state.dart';
import 'settings.dart';
import 'widgets/missing_quickemu.dart';
import 'widgets/no_vms.dart';
import 'widgets/settings_menu.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    return MaterialApp(
      builder: (context, child) {
        final virtualWindowFrame = VirtualWindowFrameInit();

        return virtualWindowFrame(context, child);
      },
      theme: AdwaitaThemeData.light(),
      darkTheme: AdwaitaThemeData.dark(),
      themeMode: settings.themeMode,
      debugShowCheckedModeBanner: false,
      home: AdwScaffold(
        actions: AdwActions().windowManager,
        title: const Text("Quickui Adw"),
        end: const [
          GtkPopupMenu(
              icon: AdwaitaIcon(AdwaitaIcons.menu), body: SettingsMenu())
        ],
        body:
            BlocBuilder<ManagerCubit, ManagerState>(builder: (context, state) {
          if (!state.quickemu) return const MissingQuickemu();
          if (state.currentVms.isEmpty) return const NoVms();
          return VmList(
              currentVms: state.currentVms, activeVms: state.activeVms);
        }),
      ),
    );
  }
}
