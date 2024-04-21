import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../infrastructure/download_infrastructure.dart';
import '../model/download_description.dart';
import 'download_state.dart';

class DownloadCubit extends Cubit<DownloaderState> {
  final DownloadInfrastructure downloader;
  final _processes = <String, Process>{};

  DownloadCubit(this.downloader) : super(DownloaderState.empty());

  Future<void> loadChoices() {
    return downloader.loadChoices().forEach((element) {
      emit(state.copyWith(
          choices: UnmodifiableListView([...state.choices, element])));
    });
  }

  Future<bool> start(final DownloadDescription description) async {
    final name = description.name;
    if (_processes.containsKey(name)) {
      return (await _processes[name]!.exitCode) == 0;
    }
    emit(state.copyWith(
        downloads:
            UnmodifiableListView([...state.downloads, Download(name: name)])));
    final process = await downloader.start(description);
    _processes[name] = process;
    process.exitCode.then(
      (exitCode) => _updateDownload(
          name, (download) => download.copyWith(exitCode: exitCode)),
    );
    downloader.progress(process, description.option).listen(
          (progress) => _updateDownload(
              name, (download) => download.copyWith(progress: progress)),
        );
    return (await process.exitCode) == 0;
  }

  void stop(DownloadDescription description) => stopByName(description.name);

  void stopByName(String name) {
    _processes[name]?.kill();
    // Is this needed?
    _updateDownload(name, (download) => download.copyWith(exitCode: -1));
  }

  _updateDownload(String name, Download Function(Download download) update) {
    final index =
        state.downloads.indexWhere((download) => download.name == name);
    final newDownloads = [...state.downloads];
    final oldDownload = state.downloads[index];
    newDownloads[index] = update(oldDownload);
    emit(state.copyWith(downloads: UnmodifiableListView(newDownloads)));
  }

  @override
  void onChange(Change<DownloaderState> change) {
    if (kDebugMode) print(change);
    super.onChange(change);
  }
}
