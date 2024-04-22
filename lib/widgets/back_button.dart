
import 'package:flutter/material.dart';
import 'package:libadwaita/libadwaita.dart';

class BackButton extends StatelessWidget {
  const BackButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AdwHeaderButton(
      icon: const Icon(Icons.navigate_before),
      isActive: Navigator.of(context).canPop(),
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
