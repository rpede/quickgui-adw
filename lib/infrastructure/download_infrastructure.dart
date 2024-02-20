import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../model/download_description.dart';
import '../model/operating_system.dart';
import '../model/option.dart';
import '../model/version.dart';

class DownloadInfrastructure {
  final wgetPattern = RegExp("( [0-9.]+%)");
  final macRecoveryPattern = RegExp("([0-9]+\\.[0-9])");
  final ariaPattern = RegExp("([0-9.]+%)");

  Future<List<OperatingSystem>> loadChoices() async {
    final process = await Process.run('quickget', ['list_csv']);
    final stdout = process.stdout as String;
    final output = <OperatingSystem>[];

    OperatingSystem? currentOperatingSystem;
    Version? currentVersion;

    stdout
        .split('\n')
        .skip(1)
        .where((element) => element.isNotEmpty)
        .map((e) => e.trim())
        .forEach((element) {
      var chunks = element.split(",");
      List<String> supportedVersion;
      if (chunks.length == 4) // Legacy version of quickget
      {
        supportedVersion = [...chunks, "wget"];
      } else {
        supportedVersion = chunks.take(5).toList();
      }

      if (currentOperatingSystem?.code != supportedVersion[1]) {
        currentOperatingSystem =
            OperatingSystem(supportedVersion[0], supportedVersion[1]);
        output.add(currentOperatingSystem!);
        currentVersion = null;
      }
      if (currentVersion?.version != supportedVersion[2]) {
        currentVersion = Version(supportedVersion[2]);
        currentOperatingSystem!.versions.add(currentVersion!);
      }
      currentVersion!.options
          .add(Option(supportedVersion[3], supportedVersion[4]));
    });

    return output;
  }

  Future<Process> start(DownloadDescription description) async {
    var arguments = [
      description.operatingSystem.code,
      description.version.version,
      if (description.option != null) description.option!.option
    ];
    final process = await Process.start('quickget', arguments);
    return process;
  }

  Stream<double> progress(Process process, Option? option) {
    return switch (option?.downloader) {
      'wget' => process.stderr.transform(utf8.decoder).transform(
          StreamTransformer.fromHandlers(handleData: parseWgetProgress)),
      'macrecovery' => process.stdout.transform(utf8.decoder).transform(
          StreamTransformer.fromHandlers(handleData: parseMacRecoveryProgress)),
      'aria2c' => process.stderr.transform(utf8.decoder).transform(
          StreamTransformer.fromHandlers(handleData: parseAriaProgress)),
      _ => Stream.value(-1),
    };
  }

  void parseWgetProgress(String line, EventSink<double> sink) {
    var matches = wgetPattern.allMatches(line).toList();
    if (matches.isNotEmpty) {
      var percent = matches[0].group(1);
      if (percent != null) {
        var value = double.parse(percent.replaceAll('%', '')) / 100.0;
        sink.add(value);
      }
    }
  }

  void parseAriaProgress(String line, EventSink<double> sink) {
    var matches = ariaPattern.allMatches(line).toList();
    if (matches.isNotEmpty) {
      var percent = matches[0].group(1);
      if (percent != null) {
        var value = double.parse(percent.replaceAll('%', '')) / 100.0;
        sink.add(value);
      }
    }
  }

  void parseMacRecoveryProgress(String line, EventSink<double> sink) {
    var matches = macRecoveryPattern.allMatches(line).toList();
    if (matches.isNotEmpty) {
      var size = matches[0].group(1);
      if (size != null) {
        var value = double.parse(size);
        sink.add(value);
      }
    }
  }
}
