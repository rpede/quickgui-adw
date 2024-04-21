import 'dart:convert';
import 'dart:core';
import 'dart:io';

import '../cli/commands.dart';
import '../cli/terminal_emulator.dart';

class ManagerInfrastructure {
  ManagerInfrastructure(
      {Commands? commands, TerminalEmulator? terminalEmulator})
      : commands = commands ?? Commands(),
        terminalEmulator = terminalEmulator ?? TerminalEmulator();

  final Commands commands;
  final TerminalEmulator terminalEmulator;

  Future<String?> getTerminalEmulator() =>
      terminalEmulator.getTerminalEmulator();

  Future<bool> detectSpice() => commands.commandExists('spicy');

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

  Future<Process> connectSpice(String spicePort) =>
      commands.spicy(port: spicePort);

  Future<Process> connectSsh(String sshPort, String username) async {
    List<String> sshArgs = ['ssh', '-p', sshPort, '$username@localhost'];
    return terminalEmulator.start(sshArgs);
  }

  Future<Process> runVm(String name) async {
    final spice = await detectSpice();
    return await commands.quickEmuRunVm(
        config: '$name.conf', display: spice ? 'spice' : null);
  }

  Future<bool> killVm(String name) => commands.pkill(name);

  Future<int> deleteVm(String name, String option) async {
    assert(['vm', 'disk'].contains(option));
    final process = await commands.quickEmuDeleteVm('$name.conf', option);
    return await process.exitCode;
  }
}
