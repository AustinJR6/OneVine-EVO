import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/daily_challenge_provider.dart';
import '../state/firestore_providers.dart';

class ChallengeScreen extends ConsumerWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenge'),
      ),
      body: Consumer(
        builder: (context, WidgetRef ref, _) {
          final state = ref.watch(dailyChallengeProvider);
          final userAsync = ref.watch(userDataProvider);

          if (state.loading || userAsync.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = userAsync.value;
          if (user == null) {
            return const Center(child: Text('User data not found.'));
          }

          if (state.challengeText == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () => ref.read(dailyChallengeProvider.notifier).fetchChallenge(),
                child: const Text('Load Today\'s Challenge'),
              ),
            );
          }

          if (state.error != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error!)),
                );
                ref.read(dailyChallengeProvider.notifier).clearError();
              });
            }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Today\'s Challenge:',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          state.challengeText!,
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Card(
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tokens: ${user.tokenCount}',
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0),
                        Text('Streak: ${user.streak} days', style: const TextStyle(fontSize: 16.0)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.loading
                            ? null
                            : () async {
                                await ref
                                    .read(dailyChallengeProvider.notifier)
                                    .handleComplete();
                              },
                        child: const Text('Mark Completed'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.loading || user.tokenCount < 3
                            ? null
                            : () async {
                                await ref
                                    .read(dailyChallengeProvider.notifier)
                                    .handleSkip();
                              },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        child: const Text('Skip Challenge'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {},
                  child: const Text('View Journal'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

