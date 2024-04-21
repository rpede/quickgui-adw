import 'dart:async';
import 'dart:io';

import 'package:quickgui/infrastructure/quickget_cli.dart';
import 'package:quickgui/infrastructure/quickget_parser.dart';

import '../model/download_description.dart';
import '../model/operating_system.dart';
import '../model/option.dart';

class DownloadInfrastructure {
  DownloadInfrastructure({QuickGetCli? cli, QuickGetParser? parser})
      : cli = cli ?? QuickGetCli(),
        parser = parser ?? QuickGetParser();
  final QuickGetCli cli;
  final QuickGetParser parser;

  Stream<OperatingSystem> loadChoices() async* {
    await for (final os in parser.parseListCsv(await cli.listCsv())) {
      yield os;
    }
  }

  Future<Process> start(DownloadDescription description) async {
    var arguments = [
      description.operatingSystem.code,
      description.version.version,
      if (description.option != null) description.option!.option
    ];
    return cli.download(arguments);
  }

  Stream<double> progress(Process process, Option? option) {
    return parser.progress(process, option);
  }
}
