import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:path/path.dart' as path;

import '../model/vminfo.dart';

class ManagerInfrastructure {
  final List<String> _supportedTerminalEmulators = [
    'cool-retro-term',
    'gnome-terminal',
    'kgx',
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

  Future<bool> detectSsh(String port) async {
    bool isSSH = false;
    try {
      Socket socket = await Socket.connect('localhost', int.parse(port));
      isSSH = await socket.any((event) => utf8.decode(event).contains('SSH'));
      socket.close();
      return isSSH;
    } catch (exception) {
      return false;
    }
  }

  Future<Process> connectSpice(String spicePort) {
    return Process.start('spicy', ['-p', spicePort]);
  }

  Future<Process> connectSsh(String sshPort, String username) async {
    List<String> sshArgs = ['ssh', '-p', sshPort, '$username@localhost'];
    // Set the arguments to execute the ssh command in the default terminal.
    // Strip the extension as x-terminal-emulator may point to a .wrapper
    final terminalEmulator = await getTerminalEmulator();
    if (terminalEmulator == null) {
      throw Exception(
          'Terminal emulator "$terminalEmulator" is not supported!');
    }
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
    return Process.start(terminalEmulator, sshArgs);
  }

  Future<VmInfo> runVm(String name) async {
    List<String> args = ['--vm', '$name.conf'];
    if (await detectSpice()) {
      args.addAll(['--display', 'spice']);
    }
    await Process.start('quickemu', args);
    VmInfo info = parseVmInfo(name);
    return info;
  }

  VmInfo parseVmInfo(name) {
    String? sshPort;
    String? spicePort;
    File portsFile = File(name + '/' + name + '.ports');
    if (portsFile.existsSync()) {
      List<String> lines = portsFile.readAsLinesSync();
      for (var line in lines) {
        List<String> parts = line.split(',');
        switch (parts[0]) {
          case 'ssh':
            sshPort = parts[1];
            break;
          case 'spice':
            spicePort = parts[1];
            break;
        }
      }
    }
    return VmInfo(name: name, spicePort: spicePort, sshPort: sshPort);
  }

  Future<int> killVm(String name) async {
    final result = await Process.run('killall', [name]);
    return result.exitCode;
  }

  Future<int> deleteVm(String name, String option) async {
    assert(['vm', 'disk'].contains(option));
    List<String> args = ['--vm', '$name.conf', '--delete-$option'];
    final result = await Process.run('quickemu', args);
    return result.exitCode;
  }

  Stream<({String name, bool active})> getVms() async* {
    await for (var entity
        in Directory.current.list(recursive: false, followLinks: true)) {
      if ((entity.path.endsWith('.conf')) && (isValidConf(entity.path))) {
        String name = path.basenameWithoutExtension(entity.path);
        var active = false;
        File pidFile = File('$name/$name.pid');
        if (pidFile.existsSync()) {
          String pid = pidFile.readAsStringSync().trim();
          Directory procDir = Directory('/proc/$pid');
          if (procDir.existsSync()) {
            active = true;
          }
        }
        yield (name: name, active: active);
      }
    }
  }

  bool isValidConf(conf) {
    List<String> lines = File(conf).readAsLinesSync();
    for (var line in lines) {
      List<String> parts = line.split('=');
      if (parts[0] == 'guest_os') {
        return true;
      }
    }
    return false;
  }
}
