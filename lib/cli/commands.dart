import 'dart:io';

class Commands {
  Future<Process> quickGetListCsv() => Process.start('quickget', ['list_csv']);

  Future<Process> quickGet(List<String> arguments) =>
      Process.start('quickget', arguments);

  Future<Process> quickEmuRunVm(
      {required String config, String? display}) async {
    List<String> args = ['--vm', config];
    if (display != null) {
      args.addAll(['--display', display]);
    }
    return await Process.start('quickemu', args);
  }

  Future<Process> quickEmuDeleteVm(String config, String option) async {
    assert(['vm', 'disk'].contains(option));
    List<String> args = ['--vm', config, '--delete-$option'];
    return await Process.start('quickemu', args);
  }

  Future<Process> spicy({String? port}) {
    return Process.start('spicy', port != null ? ['-p', port] : []);
  }

  Future<bool> pkill(String name) async {
    final result = await Process.run("pkill", ['-f', name]);
    return result.exitCode == 0;
  }

  Future<bool> commandExists(String command) async {
    ProcessResult result = await Process.run('which', [command]);
    return result.exitCode == 0;
  }
}
