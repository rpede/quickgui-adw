import 'dart:io';

import 'package:path/path.dart' as path;

class TerminalEmulator {
  final List<String> supportedTerminalEmulators = const [
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
      if (supportedTerminalEmulators.contains(terminalEmulator)) {
        return path.basename(terminalEmulator);
      }
    } else {
      for (final terminal in supportedTerminalEmulators) {
        ProcessResult result = await Process.run('which', [terminal]);
        if (result.exitCode == 0) {
          return terminal;
        }
      }
    }
    return null;
  }

  Future<Process> startInTerminalEmulator(
      String terminalEmulator, List<String> arguments) async {
    if (!supportedTerminalEmulators.contains(terminalEmulator)) {
      throw Exception(
          'Terminal emulator "$terminalEmulator" is not supported!');
    }
    var args = [...arguments];
    switch (terminalEmulator) {
      case 'gnome-terminal':
      case 'mate-terminal':
      case 'kgx':
        args.insert(0, '--');
        break;
      case 'xterm':
      case 'lxterm':
      case 'uxterm':
      case 'konsole':
      case 'uxrvt':
      case 'xrvt':
      case 'sakura':
      case 'pterm':
      case 'lxterminal':
      case 'tilix':
        args.insert(0, '-e');
        break;
      case 'terminator':
      case 'xfce4-terminal':
        args.insert(0, '-x');
        break;
      case 'guake':
        String command = args.join(' ');
        args = ['-e', command];
        break;
      default:
        throw "Unsupported terminal emulator";
    }
    return Process.start(terminalEmulator, args);
  }

  Future<Process> start(List<String> arguments) async {
    final terminalEmulator = await getTerminalEmulator();
    if (terminalEmulator == null) {
      throw Exception("No supported terminal emulator was found!");
    }
    return await startInTerminalEmulator(terminalEmulator, arguments);
  }
}
