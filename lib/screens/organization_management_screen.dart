import 'package:flutter/material.dart';

class OrganizationManagementScreen extends StatelessWidget {
  const OrganizationManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Organization Management')),
      body: const Center(child: Text('Organization Management Screen')),
    );
  }
}
