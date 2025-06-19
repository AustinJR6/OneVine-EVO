import 'package:flutter/material.dart';

class SelectReligionScreen extends StatelessWidget {
  const SelectReligionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Religion')),
      body: const Center(child: Text('Select Religion Screen')),
    );
  }
}
