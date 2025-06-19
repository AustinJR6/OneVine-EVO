import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/challenge_provider.dart'; // Assuming your ChallengeProvider is here

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenge'),
      ),
      body: Consumer<ChallengeProvider>(
        builder: (context, challengeProvider, child) {
          final dailyChallenge = challengeProvider.dailyChallenge;
          final user = challengeProvider.user;

          if (challengeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dailyChallenge == null || user == null) {
            return const Center(child: Text('Could not load daily challenge or user data.'));
          }

          final freeSkipsRemaining = user.weeklySkipCount == 0 ? 1 : 0;
          final nextSkipCost = user.weeklySkipCount > 0 ? (1 << (user.weeklySkipCount - 1)) : 0;


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
                          dailyChallenge.challengeText,
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
                           'Tokens: ${user.tokenBalance}',
                           style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                         ),
                         const SizedBox(height: 8.0),
                          Text(
                           'Free Skips Remaining This Week: $freeSkipsRemaining',
                            style: const TextStyle(fontSize: 16.0),
                         ),
                         if (freeSkipsRemaining == 0)
                            Text(
                              'Next Skip Cost: $nextSkipCost tokens',
                               style: const TextStyle(fontSize: 16.0),
                            ),
                       ],
                     ),
                   ),
                ),
                const SizedBox(height: 24.0),
                if (!dailyChallenge.completed && !dailyChallenge.skipped) ...[
                  ElevatedButton(
                    onPressed: () async {
                      await challengeProvider.completeChallenge();
                      // Show completion feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Challenge Completed! +3 Tokens'), // Update with actual token amount
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('Complete'),
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: user.tokenBalance >= nextSkipCost ? () async {
                       await challengeProvider.skipChallenge();
                       // Show skip feedback
                       String feedbackMessage = freeSkipsRemaining > 0
                           ? 'Challenge Skipped! Free skip used.'
                           : 'Challenge Skipped! -$nextSkipCost Tokens';
                       ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(
                           content: Text(feedbackMessage),
                           backgroundColor: Colors.orange,
                         ),
                       );
                    } : null, // Disable button if not enough tokens
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: const Text('Skip'),
                  ),
                ] else if (dailyChallenge.completed) ...[
                   const Center(
                     child: Text(
                       'Challenge Completed Today!',
                       style: TextStyle(fontSize: 18.0, color: Colors.green, fontWeight: FontWeight.bold),
                       ),
                   ),
                ] else if (dailyChallenge.skipped) ...[
                    const Center(
                     child: Text(
                       'Challenge Skipped Today.',
                       style: TextStyle(fontSize: 18.0, color: Colors.red, fontWeight: FontWeight.bold),
                       ),
                   ),
                ],
                 const SizedBox(height: 16.0),
                 TextButton(
                   onPressed: () {
                     // TODO: Navigate to Journal Screen
                     print('Navigate to Journal Screen');
                   },
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
