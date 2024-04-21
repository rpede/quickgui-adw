import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../model/operating_system.dart';
import '../model/option.dart';
import '../model/version.dart';

class QuickGetParser {
  QuickGetParser();
  Stream<OperatingSystem> parseListCsv(Process process) async* {
    final stream = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .skip(1)
        .where((event) => event.isNotEmpty)
        .map((event) => event.trim());

    OperatingSystem? currentOs;
    Version? currentVersion;
    await for (final line in stream) {
      var chunks = line.split(",");
      final name = chunks[0];
      final code = chunks[1];
      final version = chunks[2];
      final option = chunks[3];
      final downloader = chunks.elementAtOrNull(4) ?? 'wget';
      final png = chunks.elementAtOrNull(5);
      final svg = chunks.elementAtOrNull(6);

      if (currentOs?.code != code) {
        if (currentOs != null) yield currentOs;
        currentOs = OperatingSystem(name: name, code: code, png: png, svg: svg);
        currentVersion = null;
      }
      if (currentVersion?.version != version) {
        currentVersion = Version(version);
        currentOs!.versions.add(currentVersion);
      }
      currentVersion!.options.add(Option(option, downloader));
    }
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

  final _wgetPattern = RegExp("( [0-9.]+%)");
  void parseWgetProgress(String line, EventSink<double> sink) {
    var matches = _wgetPattern.allMatches(line).toList();
    if (matches.isNotEmpty) {
      var percent = matches[0].group(1);
      if (percent != null) {
        var value = double.parse(percent.replaceAll('%', '')) / 100.0;
        sink.add(value);
      }
    }
  }

  final _ariaPattern = RegExp("([0-9.]+%)");
  void parseAriaProgress(String line, EventSink<double> sink) {
    var matches = _ariaPattern.allMatches(line).toList();
    if (matches.isNotEmpty) {
      var percent = matches[0].group(1);
      if (percent != null) {
        var value = double.parse(percent.replaceAll('%', '')) / 100.0;
        sink.add(value);
      }
    }
  }

  final _macRecoveryPattern = RegExp("([0-9]+\\.[0-9])");
  void parseMacRecoveryProgress(String line, EventSink<double> sink) {
    var matches = _macRecoveryPattern.allMatches(line).toList();
    if (matches.isNotEmpty) {
      var size = matches[0].group(1);
      if (size != null) {
        var value = double.parse(size);
        sink.add(value);
      }
    }
  }
}
