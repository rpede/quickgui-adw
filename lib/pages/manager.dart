import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:quickgui/widgets/manager/vm_list_item.dart';

import '../controllers/manager_controller.dart';
import '../globals.dart';
import '../mixins/preferences_mixin.dart';
import '../model/manager.dart';
import '../model/vminfo.dart';

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
        ..._currentVms.expand((vm) => [
              _buildRow(context, vm, buttonColor),
              const Divider(),
            ])
      ],
    );
  }

  Widget _buildRow(BuildContext context, String currentVm, Color buttonColor) {
    VmInfo? vmInfo =
        _activeVms.containsKey(currentVm) ? _activeVms[currentVm]! : null;
    return VmListTile(
      name: currentVm,
      vmInfo: vmInfo,
      controller: controller,
    );
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
