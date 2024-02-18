
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../model/operating_system.dart';

class OperatingSystemIcon extends StatelessWidget {
  final iconSize = 32.0;
  const OperatingSystemIcon({
    super.key,
    required this.item,
  });

  final OperatingSystem item;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: rootBundle.load("assets/quickemu-icons/${item.code}.svg"),
      builder: (context, snapshot) => switch (snapshot.data) {
        ByteData data => SvgPicture.memory(
            data.buffer.asUint8List(),
            width: iconSize,
            height: iconSize,
          ),
        null => CircleAvatar(maxRadius: iconSize / 2, child: const Text("?"))
      },
    );
  }
}