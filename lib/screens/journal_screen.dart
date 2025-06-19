import 'package:flutter/material.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _entries = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addEntry() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _entries.add({
        'text': text,
        'timestamp': DateTime.now(),
      });
      _controller.clear();
    });
  }

  String _formatTimestamp(DateTime dt) {
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _entries.isEmpty
                  ? const Center(child: Text('No journal entries yet.'))
                  : ListView.builder(
                      itemCount: _entries.length,
                      itemBuilder: (context, index) {
                        final entry = _entries[index];
                        return ListTile(
                          title: Text(entry['text'] as String),
                          subtitle:
                              Text(_formatTimestamp(entry['timestamp'] as DateTime)),
                        );
                      },
                    ),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Write your journal entry...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addEntry,
                ),
              ),
              maxLines: null,
            ),
          ],
        ),
      ),
    );
  }
}
