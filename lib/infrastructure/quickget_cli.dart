import 'dart:io';


class QuickGetCli {
  Future<Process> listCsv() => Process.start('quickget', ['list_csv']);
  Future<Process> download(List<String> arguments) => Process.start('quickget', arguments);
}
