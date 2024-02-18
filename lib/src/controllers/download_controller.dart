import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../model/operating_system.dart';
import '../model/option.dart';
import '../model/version.dart';

class DownloadController {
  DownloadController({
    required this.operatingSystem,
    required this.version,
    this.option,
  });

  final OperatingSystem operatingSystem;
  final Version version;
  final Option? option;

  final wgetPattern = RegExp("( [0-9.]+%)");
  final macRecoveryPattern = RegExp("([0-9]+\\.[0-9])");
  final ariaPattern = RegExp("([0-9.]+%)");

  Stream<double> get progressStream => _controller.stream;

  final _controller = StreamController<double>();
  Process? _process;

  Future<int> start() async {
    var options = [operatingSystem.code, version.version];
    if (option != null) {
      options.add(option!.option);
    }
    final process = await Process.start('quickget', options);
    _process = process;

    if (option!.downloader == 'wget') {
      process.stderr.transform(utf8.decoder).forEach(parseWgetProgress);
    } else if (option!.downloader == 'zsync') {
      _controller.add(-1);
    } else if (option!.downloader == 'macrecovery') {
      process.stdout.transform(utf8.decoder).forEach(parseMacRecoveryProgress);
    } else if (option!.downloader == 'aria2c') {
      process.stderr.transform(utf8.decoder).forEach(parseAriaProgress);
    }

    final exitCode = await process.exitCode;
    _controller.close();
    return exitCode;
  }

  bool stop() {
    return _process?.kill() ?? false;
  }

  void parseWgetProgress(String line) {
    var matches = wgetPattern.allMatches(line).toList();
    if (matches.isNotEmpty) {
      var percent = matches[0].group(1);
      if (percent != null) {
        var value = double.parse(percent.replaceAll('%', '')) / 100.0;
        _controller.add(value);
      }
    }
  }

  void parseAriaProgress(String line) {
    var matches = ariaPattern.allMatches(line).toList();
    if (matches.isNotEmpty) {
      var percent = matches[0].group(1);
      if (percent != null) {
        var value = double.parse(percent.replaceAll('%', '')) / 100.0;
        _controller.add(value);
      }
    }
  }

  void parseMacRecoveryProgress(String line) {
    var matches = macRecoveryPattern.allMatches(line).toList();
    if (matches.isNotEmpty) {
      var size = matches[0].group(1);
      if (size != null) {
        var value = double.parse(size);
        _controller.add(value);
      }
    }
  }
}
