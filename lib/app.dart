import 'package:adwaita/adwaita.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';
import 'package:quickgui_adw/old/widgets/left_menu.dart';
import 'package:window_manager/window_manager.dart';

import 'settings.dart';
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
      // theme: ThemeData(primarySwatch: Colors.pink),
      // darkTheme: ThemeData.dark(),
      themeMode: settings.themeMode,
      debugShowCheckedModeBanner: false,
      home: AdwScaffold(
        actions: AdwActions().windowManager,
        title: Text("Quickui Adw"),
        end: [GtkPopupMenu(body: SettingsMenu())],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo_pink.png', width: 100, height: 100),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Click ➕ to add a virtual machine."),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
