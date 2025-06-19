import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/confessional_provider.dart';

class ConfessionalScreen extends ConsumerWidget {
  const ConfessionalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(confessionalProvider);
    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Confessional')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: provider.messages.length,
              itemBuilder: (context, index) {
                final msg = provider.messages[index];
                final isUser = msg['role'] == 'user';
                return ListTile(
                  title: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(msg['text'] ?? ''),
                    ),
                  ),
                );
              },
            ),
          ),
          if (provider.isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(hintText: 'Enter confession'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    controller.clear();
                    await ref.read(confessionalProvider).sendMessage(
                          text: text,
                          religion: 'Christian', // placeholder
                        );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
