import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../state/user_provider.dart';
import '../models/user.dart';
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
    final userService = ref.watch(userServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: StreamBuilder<User?>(
        stream: userService.streamCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('User data not found.'));
          }

          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome!', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                Text('Tokens: ${user.tokenBalance}', style: Theme.of(context).textTheme.titleLarge),
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
                  onPressed: () {
                    // TODO: Add navigation to other screens like Journal, Challenge, Profile, Quote
                  },
                const SizedBox(height: 16),
                Text('Recent Journal Entries:', style: Theme.of(context).textTheme.titleLarge),
                // TODO: Display recent journal entries
                Expanded(
                  child: ListView.builder(
                    itemCount: user.journalEntries.length,
                    itemBuilder: (context, index) {
                      final entry = user.journalEntries[index];
                      // TODO: Format journal entry display
                      return ListTile(
                        title: Text(entry['entry'] ?? 'No entry text'),
                        subtitle: Text(entry['timestamp']?.toString() ?? 'No timestamp'),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}