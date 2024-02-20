import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../infrastructure/download_infrastructure.dart';
import '../model/operating_system.dart';
import '../model/option.dart';
import '../model/version.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloadState> {
  final DownloadInfrastructure downloader;
  final _processes = <String, Process>{};

  DownloadCubit(this.downloader) : super([]);

  downloadName(
    final OperatingSystem operatingSystem,
    final Version version,
    final Option? option,
  ) {
    return [
      operatingSystem.code,
      version.version,
      if (option != null) option.option
    ].join('-');
  }

  Future<bool> start(
    final OperatingSystem operatingSystem,
    final Version version,
    final Option? option,
  ) async {
    final name = downloadName(operatingSystem, version, option);
    if (_processes.containsKey(name)) {
      return (await _processes[name]!.exitCode) == 0;
    }
    emit([...state, Download(name: name)]);
    final process = await downloader.start(
      operatingSystem: operatingSystem,
      version: version,
      option: option,
    );
    _processes[name] = process;
    process.exitCode.then(
      (exitCode) => _updateDownload(
          name, (download) => download.copyWith(exitCode: exitCode)),
    );
    downloader.progress(process, option).listen(
          (progress) => _updateDownload(
              name, (download) => download.copyWith(progress: progress)),
        );
    return (await process.exitCode) == 0;
  }

  _updateDownload(String name, Download Function(Download download) update) {
    final index = state.indexWhere((download) => download.name == name);
    final newState = [...state];
    final oldDownload = state[index];
    newState[index] = update(oldDownload);
    emit(newState);
  }

  void stop(
    final OperatingSystem operatingSystem,
    final Version version,
    final Option? option,
  ) =>
      stopByName(downloadName(operatingSystem, version, option));

  void stopByName(String downloadName) {
    _processes[downloadName]?.kill();
    final index = state.indexWhere((d) => d.name == downloadName);
    final newState = [...state];
    newState[index] = state[index].copyWith(exitCode: 1);
    emit(newState);
  }

  @override
  void onChange(Change<DownloadState> change) {
    if (kDebugMode) print(change);
    super.onChange(change);
  }
}
