import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:quickgui/controllers/manager_controller.dart';
import 'package:quickgui/model/vminfo.dart';

import '../../model/manager.dart';
import 'dialogs.dart';

class VmListTile extends StatelessWidget {
  const VmListTile(
      {required this.name,
      required this.controller,
      required this.vmInfo,
      super.key});
  final String name;
  final ManagerController controller;
  final VmInfo? vmInfo;

  void _onRunPressed(String currentVm) async {
    final info = await controller.runVm(currentVm);
    // setState(() {
    //   _activeVms[currentVm] = info;
    // });
  }

  Future<void> _onStopPressed(BuildContext context, String currentVm) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StopVmDialog(vmName: currentVm),
    );
    if (result ?? false) {
      controller.killVm(currentVm);
      // setState(() {
      //   _activeVms.remove(currentVm);
      // });
    }
  }

  Future<void> _onDeletePressed(BuildContext context, String currentVm) async {
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => DeleteVmDialog(vmName: currentVm),
    );
    if ((result ?? 'cancel') != 'cancel') {
      controller.deleteVm(currentVm, DeleteVmOption.values.byName(result!));
    }
  }

  Future<void> _onSshConnectPressed(
      BuildContext context, String currentVm, String sshPort) async {
    TextEditingController usernameController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SshConnectDialog(
          vmName: currentVm, usernameController: usernameController),
    );
    if (result ?? false) {
      controller.connectSsh(sshPort, usernameController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Theme.of(context).colorScheme.primary;
    final active = vmInfo != null;
    final spice = vmInfo?.spicePort != null;
    final ssh = vmInfo?.sshPort != null;
    String connectInfo = '';
    if (spice) {
      connectInfo += '${context.t('SPICE port')}: ${vmInfo?.spicePort!} ';
    }
    if (ssh) {
      connectInfo += '${context.t('SSH port')}: ${vmInfo?.sshPort!} ';
      // TODO fix ssh check
      // controller.detectSsh(vmInfo!.sshPort!).then((sshRunning) {
      //   if (sshRunning && !sshy) {
      //     setState(() {
      //       _sshVms.add(currentVm);
      //     });
      //   } else if (!sshRunning && sshy) {
      //     setState(() {
      //       _sshVms.remove(currentVm);
      //     });
      //   }
      // });
    }
    return ListTile(
      title: Text(name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (connectInfo.isNotEmpty) ...[
            IconButton(
              icon: Icon(
                Icons.monitor,
                color: spice ? buttonColor : null,
                semanticLabel: 'Connect display with SPICE',
              ),
              tooltip: spice
                  ? 'Connect display with SPICE'
                  : 'SPICE client not found',
              onPressed: spice
                  ? () => controller.connectSpice(vmInfo!.spicePort!)
                  : null,
            ),
            IconButton(
              icon: SvgPicture.asset('assets/images/console.svg',
                  semanticsLabel: 'Connect with SSH',
                  color: ssh ? buttonColor : Colors.grey),
              tooltip:
                  ssh ? 'Connect with SSH' : 'SSH server not detected on guest',
              onPressed: ssh
                  ? () => _onSshConnectPressed(context, name, vmInfo!.sshPort!)
                  : null,
            ),
          ],
          IconButton(
            icon: Icon(
              active ? Icons.play_arrow : Icons.play_arrow_outlined,
              color: active ? Colors.green : buttonColor,
              semanticLabel: active ? 'Running' : 'Run',
            ),
            onPressed: active ? null : () => _onRunPressed(name),
          ),
          IconButton(
            icon: Icon(
              active ? Icons.stop : Icons.stop_outlined,
              color: active ? Colors.red : null,
              semanticLabel: active ? 'Stop' : 'Not running',
            ),
            onPressed: !active ? null : () => _onStopPressed(context, name),
          ),
          IconButton(
            icon: Icon(
              Icons.delete,
              color: active ? null : buttonColor,
              semanticLabel: 'Delete',
            ),
            onPressed: active ? null : () => _onDeletePressed(context, name),
          ),
        ],
      ),
      subtitle: connectInfo.isNotEmpty
          ? Text(connectInfo, style: const TextStyle(fontSize: 12))
          : null,
    );
  }
}
