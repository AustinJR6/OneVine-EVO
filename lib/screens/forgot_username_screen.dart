import 'package:flutter/material.dart';

class ForgotUsernameScreen extends StatelessWidget {
  const ForgotUsernameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Username')),
      body: const Center(child: Text('Forgot Username Screen')),
    );
  }
}
