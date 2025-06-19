import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/religion_ai_provider.dart';

class ReligionAIScreen extends ConsumerStatefulWidget {
  const ReligionAIScreen({super.key});

  @override
  ConsumerState<ReligionAIScreen> createState() => _ReligionAIScreenState();
}

class _ReligionAIScreenState extends ConsumerState<ReligionAIScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(religionAIProvider);
    final notifier = ref.read(religionAIProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Ask Spiritual Question')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: notifier.updateQuestion,
              decoration: const InputDecoration(
                hintText: 'Enter your question',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: state.loading
                  ? null
                  : () => notifier.askQuestion(_controller.text),
              child: state.loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ask'),
            ),
            const SizedBox(height: 12),
            if (state.error != null)
              Text(state.error!, style: const TextStyle(color: Colors.red)),
            if (state.response.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(state.response),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
