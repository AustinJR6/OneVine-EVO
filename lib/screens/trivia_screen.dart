import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/trivia_provider.dart';

class TriviaScreen extends ConsumerStatefulWidget {
  const TriviaScreen({super.key});

  @override
  ConsumerState<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends ConsumerState<TriviaScreen> {
  final TextEditingController _religionController = TextEditingController();
  final TextEditingController _storyController = TextEditingController();

  @override
  void dispose() {
    _religionController.dispose();
    _storyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(triviaProvider);
    final notifier = ref.read(triviaProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Trivia')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: state.loading ? null : notifier.fetchTriviaQuestion,
              child: const Text('Get Question'),
            ),
            const SizedBox(height: 12),
            if (state.story != null)
              Text(state.story!),
            const SizedBox(height: 12),
            TextField(
              controller: _religionController,
              decoration: const InputDecoration(
                labelText: 'Religion Guess',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _storyController,
              decoration: const InputDecoration(
                labelText: 'Story Guess',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: state.loading || state.storyId == null
                  ? null
                  : () => notifier.submitGuess(
                        _religionController.text,
                        _storyController.text,
                      ),
              child: state.loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Guess'),
            ),
            const SizedBox(height: 12),
            if (state.error != null)
              Text(state.error!, style: const TextStyle(color: Colors.red)),
            if (state.resultText != null)
              Text(state.resultText!),
          ],
        ),
      ),
    );
  }
}
