import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';
import 'package:quickgui_adw/model/vminfo.dart';
import 'package:quickgui_adw/widgets/vm_row.dart';

class VmList extends StatelessWidget {
  const VmList({required this.currentVms, required this.activeVms, super.key});

  final List<String> currentVms;
  final Map<String, VmInfo> activeVms;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AdwClamp.scrollable(
        child: Column(
          children: [
            AdwPreferencesGroup(
              children: [
                for (final vm in currentVms)
                  VmRow(key: ValueKey(vm), name: vm, vmInfo: activeVms[vm])
              ],
            ),
          ],
        ),
      ),
    );
  }
}
