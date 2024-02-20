import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../model/operating_system.dart';
import '../model/option.dart';
import '../model/version.dart';

class DownloadInfrastructure {
  final wgetPattern = RegExp("( [0-9.]+%)");
  final macRecoveryPattern = RegExp("([0-9]+\\.[0-9])");
  final ariaPattern = RegExp("([0-9.]+%)");

  Future<Process> start({
    required final OperatingSystem operatingSystem,
    required final Version version,
    required final Option? option,
  }) async {
    var arguments = [
      operatingSystem.code,
      version.version,
      if (option != null) option.option
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
