import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Image.asset('assets/images/logo_pink.png'),
    );
  }
}
