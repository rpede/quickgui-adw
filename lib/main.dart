import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'bloc/download_cubit.dart';
import 'bloc/manager_cubit.dart';
import 'infrastructure/download_infrastructure.dart';
import 'infrastructure/manager_infrastructure.dart';
import 'infrastructure/vm_config_infrastructure.dart';
import 'mixins/app_version.dart';
import 'settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(1000, 600),
    minimumSize: Size(400, 450),
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
  // Don't forget to also change the size in linux/my_application.cc:50
  // setWindowMinSize(const Size(692, 580));
  // setWindowMaxSize(const Size(692, 580));
  final foundQuickGet = await Process.run('which', ['quickget']);
  if (foundQuickGet.exitCode == 0) {
    AppVersion.packageInfo = await PackageInfo.fromPlatform();
  }
  final settings = Settings(await SharedPreferences.getInstance());
  if (settings.workingDirectory != null) {
    Directory.current = settings.workingDirectory;
  }
  runApp(
    MultiBlocProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        BlocProvider(
            create: (_) =>
                ManagerCubit(VmConfigInfrastructure(), ManagerInfrastructure())
                  ..checkEnvironment()),
        BlocProvider(create: (_) => DownloadCubit(DownloadInfrastructure())),
      ],
      child: const App(),
    ),
  );
}
