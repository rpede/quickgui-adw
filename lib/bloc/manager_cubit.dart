import 'package:flutter_bloc/flutter_bloc.dart';

import '../infrastructure/manager_infrastructure.dart';
import '../model/vminfo.dart';
import 'manager_state.dart';

class ManagerCubit extends Cubit<ManagerState> {
  final ManagerInfrastructure controller;

  ManagerCubit(this.controller) : super(ManagerState.empty());

  get path => null;

  checkEnvironment() {
    controller
        .detectSpice()
        .then((spice) => emit(state.copyWith(spice: spice)));
    controller.getTerminalEmulator().then((terminalEmulator) =>
        emit(state.copyWith(terminalEmulator: terminalEmulator)));
  }

  refreshVms() async {
    List<String> currentVms = [];
    Map<String, VmInfo> activeVms = {};

    await for (final vm in controller.getVms()) {
      currentVms.add(vm.name);
      if (vm.active) {
        if (state.activeVms.containsKey(vm.name)) {
          activeVms[vm.name] = state.activeVms[vm.name]!;
        } else {
          activeVms[vm.name] = controller.parseVmInfo(vm.name);
        }
      }
    }
    currentVms.sort();
    emit(state.copyWith(currentVms: currentVms, activeVms: activeVms));

    // TODO fix ssh check
    // for (var vmInfo in activeVms.values.where((vmInfo) => vmInfo.sshPort != null)) {
    //   controller.detectSsh(vmInfo.sshPort!).then((sshRunning) {
    //     if (sshRunning && !sshy) {
    //       setState(() {
    //         _sshVms.add(currentVm);
    //       });
    //     } else if (!sshRunning && sshy) {
    //       setState(() {
    //         _sshVms.remove(currentVm);
    //       });
    //     }
    //   });
    // }
  }

  startVm(String name) async {
    final info = await controller.runVm(name);
    emit(state.copyWith(
      currentVms: [name, ...state.currentVms],
      activeVms: {name: info}..addAll(state.activeVms),
    ));
  }

  stopVm(String name) async {
    final exitCode = await controller.killVm(name);
    if (exitCode == 0) {
      emit(state.copyWith(
        currentVms: [...state.currentVms]..remove(name),
        activeVms: {...state.activeVms}..remove(name),
      ));
    }
  }

  deleteVm(String name, String option) async {
    final exitCode = await controller.deleteVm(name, option);
    if (exitCode == 0) {
      emit(state.copyWith(
        currentVms: [...state.currentVms]..remove(name),
        activeVms: {...state.activeVms}..remove(name),
      ));
    }
  }

  void connectSpice(VmInfo vmInfo) {
    assert(vmInfo.spicePort != null);
    controller.connectSpice(vmInfo.spicePort!);
  }

  void connectSsh(VmInfo vmInfo, String username) {
    assert(vmInfo.sshPort != null);
    controller.connectSsh(vmInfo.spicePort!, username);
  }
}
