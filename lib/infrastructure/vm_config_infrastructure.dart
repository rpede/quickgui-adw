import 'dart:io';

import 'package:path/path.dart' as path;

import '../model/vminfo.dart';

class VmConfigInfrastructure {
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
