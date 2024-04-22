import 'dart:async';
import 'dart:core';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gettext_i18n/gettext_i18n.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:libadwaita_window_manager/libadwaita_window_manager.dart';

import '../bloc/manager_cubit.dart';
import '../bloc/manager_state.dart';
import '../settings.dart';
import '../widgets/manager/vm_list_item.dart';

/// VM manager page.
/// Displays a list of available VMs, running state and connection info,
/// with buttons to start and stop VMs.
class Manager extends StatefulWidget {
  const Manager({super.key});

  @override
  State<Manager> createState() => _ManagerState();
}

class _ManagerState extends State<Manager> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    context.read<ManagerCubit>().refreshVms();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      context.read<ManagerCubit>().refreshVms();
    }); // Reload VM list every 5 seconds.
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _onTapCurrentPath() async {
    final bloc = context.read<ManagerCubit>();
    String? result = await FilePicker.platform.getDirectoryPath();
    if (result != null) {
      setState(() {
        Directory.current = result;
      });
      if (mounted) {
        context.read<Settings>().setWorkingDirectory(Directory.current.path);
      }
      bloc.refreshVms();
    }
  }

  Widget _buildDirectoryTile(BuildContext context) {
    return Padding(
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
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdwScaffold(
      actions: AdwActions().windowManager,
      start: [BackButton()],
      title: Text(context.t('Manager')),
      body: BlocBuilder<ManagerCubit, ManagerState>(builder: (context, state) {
        final activeVms = state.activeVms;
        final currentVms = state.currentVms;
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildDirectoryTile(context),
            const Divider(thickness: 2),
            ...currentVms.expand(
              (vm) => [
                VmListTile(name: vm, vmInfo: activeVms[vm]),
                const Divider(),
              ],
            )
          ],
        );
      }),
    );
  }
}
