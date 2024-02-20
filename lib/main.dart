import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'bloc/download_cubit.dart';
import 'bloc/manager_cubit.dart';
import 'infrastructure/download_infrastructure.dart';
import 'infrastructure/manager_infrastructure.dart';
import 'mixins/app_version.dart';
import 'model/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Don't forget to also change the size in linux/my_application.cc:50
  // setWindowMinSize(const Size(692, 580));
  // setWindowMaxSize(const Size(692, 580));
  final foundQuickGet = await Process.run('which', ['quickget']);
  if (foundQuickGet.exitCode == 0) {
    AppVersion.packageInfo = await PackageInfo.fromPlatform();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettings()),
      ],
      builder: (context, _) => MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) =>
                  ManagerCubit(ManagerInfrastructure())..checkEnvironment()),
          BlocProvider(
              create: (_) =>
                  DownloadCubit(DownloadInfrastructure())..loadChoices()),
        ],
        child: const App(),
      ),
    ),
  );
}
