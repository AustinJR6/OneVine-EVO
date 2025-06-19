import 'package:flutter/material.dart';

class LeaderboardsScreen extends StatelessWidget {
  const LeaderboardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboards')),
      body: const Center(child: Text('Leaderboards Screen')),
    );
  }
}
