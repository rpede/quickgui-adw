import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

import '../controllers/manager_controller.dart';
import '../globals.dart';
import '../mixins/preferences_mixin.dart';
import '../model/manager.dart';
import '../model/vminfo.dart';
import '../widgets/manager/dialogs.dart';

/// VM manager page.
/// Displays a list of available VMs, running state and connection info,
/// with buttons to start and stop VMs.
class Manager extends StatefulWidget {
  const Manager({super.key});

  @override
  State<Manager> createState() => _ManagerState();
}

class _ManagerState extends State<Manager> with PreferencesMixin {
  final controller = ManagerController();
  List<String> _currentVms = [];
  Map<String, VmInfo> _activeVms = {};
  bool _spicy = false;
  final List<String> _sshVms = [];
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    controller
        .detectSpice()
        .then((available) => setState(() => _spicy = available));

    getPreference<String>(prefWorkingDirectory).then((pref) {
      setState(() {
        if (pref == null) {
          return;
        }
        Directory.current = pref;
      });
      Future.delayed(Duration.zero,
          () => _updateVms()); // Reload VM list when we enter the page.
    });

    refreshTimer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      _updateVms();
    }); // Reload VM list every 5 seconds.
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  void _updateVms() async {
    final VmStatus result = await controller.getVms(_activeVms);

    setState(() {
      _currentVms = result.currentVms;
      _activeVms = result.activeVms;
    });
  }

  Future<void> _onTapCurrentPath() async {
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        Directory.current = result;
      });

      savePreference(prefWorkingDirectory, Directory.current.path);
      _updateVms();
    }
  }

  void _onRunPressed(String currentVm) async {
    final info = await controller.runVm(currentVm);
    setState(() {
      _activeVms[currentVm] = info;
    });
  }

  Future<void> _onStopPressed(BuildContext context, String currentVm) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StopVmDialog(vmName: currentVm),
    );
    if (result ?? false) {
      controller.killVm(currentVm);
      setState(() {
        _activeVms.remove(currentVm);
      });
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
      BuildContext context, String currentVm, VmInfo vmInfo) async {
    TextEditingController usernameController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => SshConnectDialog(
          vmName: currentVm, usernameController: usernameController),
    );
    if (result ?? false) {
      controller.connectSsh(vmInfo, usernameController.text);
    }
  }

  Widget _buildVmList(BuildContext context) {
    final Color buttonColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Theme.of(context).colorScheme.primary;
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${context.t('Directory where the machines are stored')}:",
              ),
              const SizedBox(
                width: 8,
              ),
              Text.rich(
                TextSpan(
                  recognizer: TapGestureRecognizer()..onTap = _onTapCurrentPath,
                  text: Directory.current.path,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          thickness: 2,
        ),
        ..._currentVms.expand((vm) => _buildRow(context, vm, buttonColor))
      ],
    );
  }

  List<Widget> _buildRow(
      BuildContext context, String currentVm, Color buttonColor) {
    final bool active = _activeVms.containsKey(currentVm);
    final bool sshy = _sshVms.contains(currentVm);
    VmInfo vmInfo = active ? _activeVms[currentVm]! : VmInfo();
    String connectInfo = '';
    if (vmInfo.spicePort != null) {
      connectInfo += '${context.t('SPICE port')}: ${vmInfo.spicePort!} ';
    }
    if (vmInfo.sshPort != null) {
      connectInfo += '${context.t('SSH port')}: ${vmInfo.sshPort!} ';
      controller.detectSsh(int.parse(vmInfo.sshPort!)).then((sshRunning) {
        if (sshRunning && !sshy) {
          setState(() {
            _sshVms.add(currentVm);
          });
        } else if (!sshRunning && sshy) {
          setState(() {
            _sshVms.remove(currentVm);
          });
        }
      });
    }
    return <Widget>[
      ListTile(
          title: Text(currentVm),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  active ? Icons.play_arrow : Icons.play_arrow_outlined,
                  color: active ? Colors.green : buttonColor,
                  semanticLabel: active ? 'Running' : 'Run',
                ),
                onPressed: active ? null : () => _onRunPressed(currentVm),
              ),
              IconButton(
                icon: Icon(
                  active ? Icons.stop : Icons.stop_outlined,
                  color: active ? Colors.red : null,
                  semanticLabel: active ? 'Stop' : 'Not running',
                ),
                onPressed:
                    !active ? null : () => _onStopPressed(context, currentVm),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: active ? null : buttonColor,
                  semanticLabel: 'Delete',
                ),
                onPressed:
                    active ? null : () => _onDeletePressed(context, currentVm),
              ),
            ],
          )),
      if (connectInfo.isNotEmpty)
        ListTile(
          title: Text(connectInfo, style: const TextStyle(fontSize: 12)),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.monitor,
                color: _spicy ? buttonColor : null,
                semanticLabel: 'Connect display with SPICE',
              ),
              tooltip: _spicy
                  ? 'Connect display with SPICE'
                  : 'SPICE client not found',
              onPressed: !_spicy ? null : () => controller.connectSpice(vmInfo),
            ),
            IconButton(
              icon: SvgPicture.asset('assets/images/console.svg',
                  semanticsLabel: 'Connect with SSH',
                  color: sshy ? buttonColor : Colors.grey),
              tooltip: sshy
                  ? 'Connect with SSH'
                  : 'SSH server not detected on guest',
              onPressed: !sshy
                  ? null
                  : () => _onSshConnectPressed(context, currentVm, vmInfo),
            ),
          ]),
        ),
      const Divider()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t('Manager')),
      ),
      body: Builder(builder: (context) => _buildVmList(context)),
    );
  }
}
