import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/confessional_provider.dart';

class ConfessionalScreen extends ConsumerWidget {
  const ConfessionalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(confessionalProvider);
    final controller = TextEditingController(text: state.input);
    final scrollController = ScrollController();

    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.error!)));
        ref.read(confessionalProvider.notifier).clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Confessional')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[index];
                final isUser = msg['role'] == 'user';
                return ListTile(
                  title: Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
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
          if (state.loading) const LinearProgressIndicator(),
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
                  onPressed: state.loading
                      ? null
                      : () async {
                          final text = controller.text.trim();
                          if (text.isEmpty) return;
                          controller.clear();
                          await ref
                              .read(confessionalProvider.notifier)
                              .sendMessage(text);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (scrollController.hasClients) {
                              scrollController.jumpTo(
                                  scrollController.position.maxScrollExtent);
                            }
                          });
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

