import 'package:flutter/material.dart';

class OrganizationsScreen extends StatelessWidget {
  const OrganizationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organizations')),
      body: const Center(child: Text('Organizations Screen')),
    );
  }
}
