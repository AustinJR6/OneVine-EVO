import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: FutureBuilder<User?>(
        future: userService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User not found.'));
          }

          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${authService.currentUser?.email ?? 'N/A'}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                const Text('Placeholder for profile update options...', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async { await authService.signOut(); },
                  child: const Text('Logout')),
              ],
            ),
          );
        },
      ),
    );
  }
