import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

import '../../bloc/manager_cubit.dart';
import '../../model/vminfo.dart';
import 'dialogs.dart';

class VmListTile extends StatelessWidget {
  const VmListTile({required this.name, required this.vmInfo, super.key});
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
      IconButton(
        icon: Icon(
          Icons.monitor,
          color: spice ? buttonColor : null,
          semanticLabel: 'Connect display with SPICE',
        ),
        tooltip:
            spice ? 'Connect display with SPICE' : 'SPICE client not found',
        onPressed:
            spice ? () => _onSpiceConnectPressed(context, vmInfo!) : null,
      ),
      IconButton(
        icon: SvgPicture.asset('assets/images/console.svg',
            semanticsLabel: 'Connect with SSH',
            color: ssh ? buttonColor : Colors.grey),
        tooltip: ssh ? 'Connect with SSH' : 'SSH server not detected on guest',
        onPressed: ssh ? () => _onSshConnectPressed(context, vmInfo!) : null,
      ),
    ];
  }

  List<Widget> _buildManageButtons(BuildContext context, Color buttonColor) {
    final active = vmInfo != null;
    return [
      IconButton(
        icon: Icon(
          active ? Icons.play_arrow : Icons.play_arrow_outlined,
          color: active ? Colors.green : buttonColor,
          semanticLabel: active ? 'Running' : 'Run',
        ),
        onPressed: active ? null : () => _onRunPressed(context),
      ),
      IconButton(
        icon: Icon(
          active ? Icons.stop : Icons.stop_outlined,
          color: active ? Colors.red : null,
          semanticLabel: active ? 'Stop' : 'Not running',
        ),
        onPressed: !active ? null : () => _onStopPressed(context),
      ),
      IconButton(
        icon: Icon(
          Icons.delete,
          color: active ? null : buttonColor,
          semanticLabel: 'Delete',
        ),
        onPressed: active ? null : () => _onDeletePressed(context, name),
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
      if (spice) '${context.t('SPICE port')}: ${vmInfo?.spicePort!} ',
      if (ssh) '${context.t('SSH port')}: ${vmInfo?.sshPort!} ',
    ].join().trim();
    return ListTile(
      title: Text(name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (connections) ..._buildConnectionButtons(context, buttonColor),
          ..._buildManageButtons(context, buttonColor)
        ],
      ),
      subtitle: connections
          ? Text(connectionInfo, style: const TextStyle(fontSize: 12))
          : null,
    );
  }
}
