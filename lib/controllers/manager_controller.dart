import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:quickgui/model/vminfo.dart';

import '../model/manager.dart';

class ManagerController {
  final List<String> _supportedTerminalEmulators = [
    'cool-retro-term',
    'gnome-terminal',
    'guake',
    'mate-terminal',
    'konsole',
    'lxterm',
    'lxterminal',
    'pterm',
    'sakura',
    'terminator',
    'tilix',
    'uxterm',
    'uxrvt',
    'xfce4-terminal',
    'xrvt',
    'xterm'
  ];

  Future<String?> getTerminalEmulator() async {
    // Find out which terminal emulator we have set as the default.
    ProcessResult result = await Process.run('which', ['x-terminal-emulator']);
    if (result.exitCode == 0) {
      String terminalEmulator =
          await File(result.stdout.toString().trim()).resolveSymbolicLinks();
      terminalEmulator = path.basenameWithoutExtension(terminalEmulator);
      if (_supportedTerminalEmulators.contains(terminalEmulator)) {
        return path.basename(terminalEmulator);
      }
    }
    return null;
  }

  Future<bool> detectSpice() async {
    ProcessResult result = await Process.run('which', ['spicy']);
    return result.exitCode == 0;
  }

  Future<bool> detectSsh(int port) async {
    bool isSSH = false;
    try {
      Socket socket = await Socket.connect('localhost', port);
      isSSH = await socket.any((event) => utf8.decode(event).contains('SSH'));
      socket.close();
      return isSSH;
    } catch (exception) {
      return false;
    }
  }

  void connectSpice(VmInfo vmInfo) {
    Process.start('spicy', ['-p', vmInfo.spicePort!]);
  }

  Future<void> connectSsh(VmInfo vmInfo, String username) async {
    List<String> sshArgs = [
      'ssh',
      '-p',
      vmInfo.sshPort!,
      '$username@localhost'
    ];
    // Set the arguments to execute the ssh command in the default terminal.
    // Strip the extension as x-terminal-emulator may point to a .wrapper
    final terminalEmulator = await getTerminalEmulator();
    if (terminalEmulator == null) return;
    switch (path.basenameWithoutExtension(terminalEmulator)) {
      case 'gnome-terminal':
      case 'mate-terminal':
        sshArgs.insert(0, '--');
        break;
      case 'xterm':
      case 'lxterm':
      case 'uxterm':
      case 'konsole':
      case 'uxrvt':
      case 'xrvt':
      case 'sakura':
      case 'cool-retro-term':
      case 'pterm':
      case 'lxterminal':
      case 'tilix':
        sshArgs.insert(0, '-e');
        break;
      case 'terminator':
      case 'xfce4-terminal':
        sshArgs.insert(0, '-x');
        break;
      case 'guake':
        String command = sshArgs.join(' ');
        sshArgs = ['-e', command];
        break;
    }
    Process.start(terminalEmulator, sshArgs);
  }

  Future<VmInfo> runVm(String currentVm) async {
    List<String> args = ['--vm', '$currentVm.conf'];
    if (await detectSpice()) {
      args.addAll(['--display', 'spice']);
    }
    await Process.start('quickemu', args);
    VmInfo info = _parseVmInfo(currentVm);
    return info;
  }

  VmInfo _parseVmInfo(name) {
    VmInfo info = VmInfo();
    File portsFile = File(name + '/' + name + '.ports');
    if (portsFile.existsSync()) {
      List<String> lines = portsFile.readAsLinesSync();
      for (var line in lines) {
        List<String> parts = line.split(',');
        switch (parts[0]) {
          case 'ssh':
            info.sshPort = parts[1];
            break;
          case 'spice':
            info.spicePort = parts[1];
            break;
        }
      }
    }
    return info;
  }

  Future<int> killVm(String name) async {
    final result = await Process.run('killall', [name]);
    return result.exitCode;
  }

  Future<VmStatus> getVms(Map<String, VmInfo> alreadyActiveVms) async {
    List<String> currentVms = [];
    Map<String, VmInfo> activeVms = {};

    await for (var entity
        in Directory.current.list(recursive: false, followLinks: true)) {
      if ((entity.path.endsWith('.conf')) && (_isValidConf(entity.path))) {
        String name = path.basenameWithoutExtension(entity.path);
        currentVms.add(name);
        File pidFile = File('$name/$name.pid');
        if (pidFile.existsSync()) {
          String pid = pidFile.readAsStringSync().trim();
          Directory procDir = Directory('/proc/$pid');
          if (procDir.existsSync()) {
            if (alreadyActiveVms.containsKey(name)) {
              activeVms[name] = alreadyActiveVms[name]!;
            } else {
              activeVms[name] = _parseVmInfo(name);
            }
          }
        }
      }
    }
    currentVms.sort();
    return (currentVms: currentVms, activeVms: activeVms);
  }

  bool _isValidConf(conf) {
    List<String> lines = File(conf).readAsLinesSync();
    for (var line in lines) {
      List<String> parts = line.split('=');
      if (parts[0] == 'guest_os') {
        return true;
      }
    }
    return false;
  }

  Future<void> deleteVm(String name, DeleteVmOption option) async {
    List<String> args = ['--vm', '$name.conf', '--delete-${option.name}'];
    await Process.start('quickemu', args);
  }
}
