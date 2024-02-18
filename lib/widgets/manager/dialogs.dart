import 'package:flutter/material.dart';
import 'package:gettext_i18n/gettext_i18n.dart';

class StopVmDialog extends StatelessWidget {
  const StopVmDialog({required this.vmName, super.key});
  final String vmName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.t('Stop The Virtual Machine?')),
      content: Text(context
          .t('You are about to terminate the virtual machine', args: [vmName])),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.t('Cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.t('OK')),
        ),
      ],
    );
  }
}

class DeleteVmDialog extends StatelessWidget {
  const DeleteVmDialog({required this.vmName, super.key});
  final String vmName;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete $vmName'),
      content: Text(
          'You are about to delete $vmName. This cannot be undone. Would you like to delete the disk image but keep the configuration, or delete the whole VM?'),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context, 'cancel'),
        ),
        TextButton(
          child: const Text('Delete disk image'),
          onPressed: () => Navigator.pop(context, 'disk'),
        ),
        TextButton(
          child: const Text('Delete whole VM'),
          onPressed: () => Navigator.pop(context, 'vm'),
        ) // set up the AlertDialog
      ],
    );
  }
}

class SshConnectDialog extends StatelessWidget {
  const SshConnectDialog(
      {required this.vmName, required this.usernameController, super.key});
  final String vmName;
  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Launch SSH connection to $vmName'),
      content: TextField(
        controller: usernameController,
        decoration: const InputDecoration(hintText: "SSH username"),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Connect'),
        ),
      ],
    );
  }
}
