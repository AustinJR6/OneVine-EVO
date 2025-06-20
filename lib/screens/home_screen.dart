import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/firestore_providers.dart';
import '../models/user_model.dart';
import 'journal_screen.dart';
import 'challenge_screen.dart';
import 'profile_screen.dart';
import 'quote_screen.dart';
import 'religion_ai_screen.dart'; // Import the ReligionAIScreen

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (UserModel? user) {
          if (user == null) {
            return const Center(child: Text('User data not found.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome!', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                Text('Tokens: ${user.tokenCount}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Text('Daily Challenge Status:', style: Theme.of(context).textTheme.titleLarge),
                // TODO: Display actual challenge status based on user.dailyChallengeStatus
                Text('Challenge status goes here.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReligionAIScreen()),
                    );
                  },
                  child: const Text('Get Spiritual Reflection from AI'),
                ),
                 const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: const Text('More Features Coming Soon'),
                ),
                const SizedBox(height: 16),
                const Text('Recent Journal Entries feature coming soon'),
              ],
            ),
          );
        },
      ),
    );
  }
}
