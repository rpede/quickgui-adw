import 'dart:collection';

import 'package:equatable/equatable.dart';

import '../model/operating_system.dart';

class DownloaderState extends Equatable {
  final UnmodifiableListView<OperatingSystem> choices;
  final List<Download> downloads;

  const DownloaderState({
    required this.choices,
    required this.downloads,
  });

  factory DownloaderState.empty() => DownloaderState(
      choices: UnmodifiableListView([]), downloads: UnmodifiableListView([]));

  DownloaderState copyWith({
    UnmodifiableListView<OperatingSystem>? choices,
    UnmodifiableListView<Download>? downloads,
  }) =>
      DownloaderState(
        choices: choices ?? this.choices,
        downloads: downloads ?? this.downloads,
      );

  @override
  List<Object?> get props => [choices, downloads];
}

class Download extends Equatable {
  final String name;
  final int? exitCode;
  final double progress;

  bool get completed => exitCode != null;
  bool get success => exitCode == 0;

  const Download({
    required this.name,
    this.exitCode,
    this.progress = 0,
  });

  Download copyWith({
    String? name,
    int? exitCode,
    double? progress,
  }) =>
      Download(
        name: name ?? this.name,
        exitCode: exitCode ?? this.exitCode,
        progress: progress ?? this.progress,
      );

  @override
  List<Object?> get props => [name, exitCode, progress];
}
