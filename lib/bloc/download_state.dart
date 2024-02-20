import 'package:equatable/equatable.dart';

typedef DownloadState = List<Download>;

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
