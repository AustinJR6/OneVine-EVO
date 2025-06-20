import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/firestore_providers.dart';
import '../state/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDataProvider);
    final authService = ref.read(authServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email: ${authService.currentUser?.email ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                Text('Religion: ${user.religion ?? 'None'}'),
                Text('Tokens: ${user.tokenCount}'),
                Text('Streak: ${user.streak} days'),
                Text('Points: ${user.individualPoints}'),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    await authService.signOut();
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

