/// Store info about a running vm, such as connection ports.
class VmInfo {
  VmInfo({required this.name, this.sshPort, this.spicePort});
  final String name;
  final String? sshPort;
  final String? spicePort;
}
