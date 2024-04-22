import 'package:flutter_bloc/flutter_bloc.dart';

import '../infrastructure/manager_infrastructure.dart';
import '../infrastructure/vm_config_infrastructure.dart';
import '../model/vminfo.dart';
import 'manager_state.dart';

class ManagerCubit extends Cubit<ManagerState> {
  ManagerCubit(this.config, this.manager) : super(ManagerState.empty());

  final ManagerInfrastructure manager;
  final VmConfigInfrastructure config;

  get path => null;

  checkEnvironment() {
    manager.detectSpice().then((spice) => emit(state.copyWith(spice: spice)));
    manager.getTerminalEmulator().then((terminalEmulator) =>
        emit(state.copyWith(terminalEmulator: terminalEmulator)));
  }

  refreshVms() async {
    List<String> currentVms = [];
    Map<String, VmInfo> activeVms = {};

    await for (final vm in config.getVms()) {
      currentVms.add(vm.name);
      if (vm.active) {
        if (state.activeVms.containsKey(vm.name)) {
          activeVms[vm.name] = state.activeVms[vm.name]!;
        } else {
          activeVms[vm.name] = config.parseVmInfo(vm.name);
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
    await manager.runVm(name);
    final info = config.parseVmInfo(name);
    emit(state.copyWith(
      currentVms: [name, ...state.currentVms],
      activeVms: {name: info}..addAll(state.activeVms),
    ));
  }

  stopVm(String name) async {
    final exitCode = await manager.killVm(name);
    if (exitCode == 0) {
      emit(state.copyWith(
        currentVms: [...state.currentVms]..remove(name),
        activeVms: {...state.activeVms}..remove(name),
      ));
    }
  }

  deleteVm(String name, String option) async {
    final exitCode = await manager.deleteVm(name, option);
    if (exitCode == 0) {
      emit(state.copyWith(
        currentVms: [...state.currentVms]..remove(name),
        activeVms: {...state.activeVms}..remove(name),
      ));
    }
  }

  void connectSpice(VmInfo vmInfo) {
    assert(vmInfo.spicePort != null);
    manager.connectSpice(vmInfo.spicePort!);
  }

  void connectSsh(VmInfo vmInfo, String username) {
    assert(vmInfo.sshPort != null);
    manager.connectSsh(vmInfo.spicePort!, username);
  }
}
