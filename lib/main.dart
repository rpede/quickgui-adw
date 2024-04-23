import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'bloc/download_cubit.dart';
import 'bloc/manager_cubit.dart';
import 'infrastructure/download_infrastructure.dart';
import 'infrastructure/manager_infrastructure.dart';
import 'infrastructure/vm_config_infrastructure.dart';
import 'settings.dart';

Future<void> setupWindowManager() async {
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(692, 580),
    minimumSize: Size(692, 580),
    skipTaskbar: false,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Quickui Adw',
  );
  unawaited(
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (Platform.isLinux || Platform.isMacOS) {
        await windowManager.setAsFrameless();
      }
      await windowManager.show();
      await windowManager.focus();
    }),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupWindowManager();
  final settings = await Settings.create();
  runApp(
    MultiBlocProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        BlocProvider(
            create: (_) =>
                ManagerCubit(VmConfigInfrastructure(), ManagerInfrastructure())
                  ..initialize()),
        BlocProvider(create: (_) => DownloadCubit(DownloadInfrastructure())),
      ],
      child: const App(),
    ),
  );
}
