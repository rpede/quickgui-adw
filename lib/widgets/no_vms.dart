import 'package:flutter/material.dart';

class NoVms extends StatelessWidget {
  const NoVms({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo_pink.png', width: 100, height: 100),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Click ➕ to add a virtual machine."),
          ),
        ],
      ),
    );
  }
}
