import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';

class AdwBackButton extends StatelessWidget {
  const AdwBackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdwHeaderButton(
      icon: const Icon(Icons.navigate_before),
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}
