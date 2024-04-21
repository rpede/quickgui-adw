import 'dart:async';
import 'dart:io';

import '../cli/commands.dart';
import '../cli/quickget_parser.dart';
import '../model/download_description.dart';
import '../model/operating_system.dart';
import '../model/option.dart';

class DownloadInfrastructure {
  DownloadInfrastructure({Commands? commands, QuickGetParser? parser})
      : commands = commands ?? Commands(),
        parser = parser ?? QuickGetParser();

  final Commands commands;
  final QuickGetParser parser;

  Stream<OperatingSystem> loadChoices() async* {
    final process = await commands.quickGetListCsv();
    await for (final os in parser.parseListCsv(process)) {
      yield os;
    }
  }

  Future<Process> start(DownloadDescription description) async {
    var arguments = [
      description.operatingSystem.code,
      description.version.version,
      if (description.option != null) description.option!.option
    ];
    return commands.quickGet(arguments);
  }

  Stream<double> progress(Process process, Option? option) {
    return parser.progress(process, option);
  }
}
