import 'operating_system.dart';
import 'option.dart';
import 'version.dart';

class DownloadDescription {
  final OperatingSystem operatingSystem;
  final Version version;
  final Option? option;

  DownloadDescription({
    required this.operatingSystem,
    required this.version,
    required this.option,
  });

  get name => [
        operatingSystem.code,
        version.version,
        if (option != null) option?.option,
      ].join('-');
}
