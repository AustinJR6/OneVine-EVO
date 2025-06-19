import 'package:flutter/material.dart';

class TriviaScreen extends StatelessWidget {
  const TriviaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trivia')),
      body: const Center(child: Text('Trivia Screen')),
    );
  }
}
