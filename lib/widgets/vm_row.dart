import 'package:adw_icons/adw_icon.dart';
import 'package:adw_icons/adw_icon_data.dart';
import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:provider/provider.dart';

import '../bloc/manager_cubit.dart';
import '../model/vminfo.dart';
import '../old/widgets/manager/dialogs.dart';

class VmRow extends StatelessWidget {
  const VmRow({required this.name, required this.vmInfo, super.key});
  final String name;
  final VmInfo? vmInfo;

  bool get spice => vmInfo?.spicePort != null;
  bool get ssh => vmInfo?.sshPort != null;

  void _onRunPressed(BuildContext context) async {
    context.read<ManagerCubit>().startVm(name);
  }

  Future<void> _onStopPressed(BuildContext context) async {
    final cubit = context.read<ManagerCubit>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StopVmDialog(vmName: name),
    );
    if (result ?? false) {
      cubit.stopVm(name);
    }
  }

  Future<void> _onDeletePressed(BuildContext context, String currentVm) async {
    final cubit = context.read<ManagerCubit>();
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => DeleteVmDialog(vmName: currentVm),
    );
    if ((result ?? 'cancel') != 'cancel') {
      cubit.deleteVm(currentVm, result!);
    }
  }

  void _onSpiceConnectPressed(BuildContext context, VmInfo vmInfo) {
    context.read<ManagerCubit>().connectSpice(vmInfo);
  }

  Future<void> _onSshConnectPressed(BuildContext context, VmInfo vmInfo) async {
    final cubit = context.read<ManagerCubit>();
    TextEditingController usernameController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SshConnectDialog(
          vmName: vmInfo.name, usernameController: usernameController),
    );
    if (result ?? false) {
      cubit.connectSsh(vmInfo, usernameController.text);
    }
  }

  List<Widget> _buildConnectionButtons(
      BuildContext context, Color buttonColor) {
    return [
      AdwButton.flat(
        onPressed:
            spice ? () => _onSpiceConnectPressed(context, vmInfo!) : null,
        textStyle: TextStyle(
          color: spice ? buttonColor : null,
        ),
        child: const Text("🌶️", semanticsLabel: 'Connect display with SPICE'),
      ),
      const SizedBox(width: 5),
      AdwButton.flat(
        onPressed: ssh ? () => _onSshConnectPressed(context, vmInfo!) : null,
        child: AdwIcon(
          AdwIconData.legacyUtilitiesTerminalSymbolic,
          color: spice ? buttonColor : null,
          semanticLabel: 'Connect with SSH',
        ),
      ),
    ];
  }

  List<Widget> _buildManageButtons(BuildContext context, Color buttonColor) {
    final active = vmInfo != null;
    return [
      AdwButton.flat(
        onPressed: active ? null : () => _onRunPressed(context),
        child: AdwIcon(
          AdwIconData.actionsMediaPlaybackStartSymbolic,
          color: active ? Colors.green : buttonColor,
          semanticLabel: active ? 'Running' : 'Run',
        ),
      ),
      const SizedBox(width: 5),
      AdwButton.flat(
        onPressed: !active ? null : () => _onStopPressed(context),
        child: AdwIcon(
          AdwIconData.actionsMediaPlaybackStopSymbolic,
          color: active ? Colors.red : null,
          semanticLabel: active ? 'Stop' : 'Not running',
        ),
      ),
      const SizedBox(width: 5),
      AdwButton.flat(
        onPressed: active ? null : () => _onDeletePressed(context, name),
        child: AdwIcon(
          AdwIconData.actionsEditDeleteSymbolic,
          color: active ? null : buttonColor,
          semanticLabel: 'Delete',
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Theme.of(context).colorScheme.primary;
    final connections = spice || ssh;
    final connectionInfo = [
      if (spice) 'SPICE port: ${vmInfo?.spicePort!} ',
      if (ssh) 'SSH port: ${vmInfo?.sshPort!} ',
    ].join().trim();
    return AdwActionRow(
      title: name,
      end: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (connections) ..._buildConnectionButtons(context, buttonColor),
          ..._buildManageButtons(context, buttonColor)
        ],
      ),
      subtitle: connections ? connectionInfo : null,
    );
  }
}
