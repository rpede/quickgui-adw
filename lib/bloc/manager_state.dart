import 'package:equatable/equatable.dart';

import '../model/vminfo.dart';

class ManagerState extends Equatable {
  final List<String> currentVms;
  final Map<String, VmInfo> activeVms;
  final bool quickemu;
  final bool spice;
  final String? terminalEmulator;

  const ManagerState({
    required this.currentVms,
    required this.activeVms,
    required this.spice,
    required this.quickemu,
    this.terminalEmulator,
  });

  factory ManagerState.empty() =>
      const ManagerState(currentVms: [], activeVms: {}, spice: false, quickemu: true);

  ManagerState copyWith({
    List<String>? currentVms,
    Map<String, VmInfo>? activeVms,
    bool? spice,
    bool? quickemu,
    String? terminalEmulator,
  }) =>
      ManagerState(
        currentVms: currentVms ?? this.currentVms,
        activeVms: activeVms ?? this.activeVms,
        spice: spice ?? this.spice,
        quickemu: quickemu ?? this.quickemu,
        terminalEmulator: terminalEmulator ?? this.terminalEmulator,
      );

  @override
  List<Object?> get props => [currentVms, activeVms, spice, terminalEmulator];
}
