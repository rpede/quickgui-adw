import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import 'app.dart';
import 'bloc/download_cubit.dart';
import 'bloc/manager_cubit.dart';
import 'infrastructure/download_infrastructure.dart';
import 'infrastructure/manager_infrastructure.dart';
import 'mixins/app_version.dart';
import 'model/app_settings.dart';
import 'model/operating_system.dart';
import 'model/option.dart';
import 'model/version.dart';

Future<List<OperatingSystem>> loadOperatingSystems(bool showUbuntus) async {
  var process = await Process.run('quickget', ['list_csv']);
  var stdout = process.stdout as String;
  var output = <OperatingSystem>[];

  OperatingSystem? currentOperatingSystem;
  Version? currentVersion;

  stdout
      .split('\n')
      .skip(1)
      .where((element) => element.isNotEmpty)
      .map((e) => e.trim())
      .forEach((element) {
    var chunks = element.split(",");
    Tuple5 supportedVersion;
    if (chunks.length == 4) // Legacy version of quickget
    {
      supportedVersion = Tuple5.fromList([...chunks, "wget"]);
    } else {
      var t5 = [chunks[0], chunks[1], chunks[2], chunks[3], chunks[4]].toList();
      supportedVersion = Tuple5.fromList(t5);
    }

    if (currentOperatingSystem?.code != supportedVersion.item2) {
      currentOperatingSystem =
          OperatingSystem(supportedVersion.item1, supportedVersion.item2);
      output.add(currentOperatingSystem!);
      currentVersion = null;
    }
    if (currentVersion?.version != supportedVersion.item3) {
      currentVersion = Version(supportedVersion.item3);
      currentOperatingSystem!.versions.add(currentVersion!);
    }
    currentVersion!.options
        .add(Option(supportedVersion.item4, supportedVersion.item5));
  });

  return output;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Don't forget to also change the size in linux/my_application.cc:50
  // setWindowMinSize(const Size(692, 580));
  // setWindowMaxSize(const Size(692, 580));
  final foundQuickGet = await Process.run('which', ['quickget']);
  if (foundQuickGet.exitCode == 0) {
    gOperatingSystems = await loadOperatingSystems(false);
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
          BlocProvider(create: (_) => DownloadCubit(DownloadInfrastructure())),
        ],
        child: const App(),
      ),
    ),
  );
}
