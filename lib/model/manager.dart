import 'vminfo.dart';

typedef VmStatus = ({List<String> currentVms, Map<String, VmInfo> activeVms});

enum DeleteVmOption {
  disk,
  vm;
}
