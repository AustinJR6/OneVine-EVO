import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/Users/josh/Desktop/onevine/lib/services/user_service.dart';
import 'package:myapp/Users/josh/Desktop/onevine/lib/services/gemini_service.dart'; // Import GeminiService
import 'package:myapp/Users/josh/Desktop/onevine/lib/models/user.dart';


class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _journalController = TextEditingController();
  String _geminiResponse = ''; // State variable to hold Gemini's response

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  void _saveJournalEntry(UserService userService, String userId) async {
    if (_journalController.text.isNotEmpty) {
      await userService.addJournalEntry(
        userId,
        _journalController.text,
      );
      _journalController.clear();
    }
  }

  void _getGeminiAssistance(GeminiService geminiService, String entryText) async {
    setState(() {
      _geminiResponse = 'Getting assistance from Gemini...'; // Indicate loading
    });
    // TODO: Call GeminiService to get assistance
    // Replace with actual API call using geminiService.getJournalAssistance(entryText)
    final response = await Future.delayed(Duration(seconds: 2), () => "This is a placeholder Gemini response for: \"$entryText\""); // Placeholder delay and response
    setState(() {
      _geminiResponse = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    // Assuming you have a way to get the current user's ID, perhaps from AuthService or a state management solution
    final String userId = 'CURRENT_USER_ID'; // Replace with actual user ID retrieval

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
      ), // Added missing closing parenthesis for AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<User?>(
                // Assuming streamUser method exists in UserService to stream user data
                // You might need to adjust this based on your actual UserService implementation
                stream: userService.streamUser(userId), // TODO: Implement streamUser in UserService
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading journal entries: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data == null || snapshot.data!.journalEntries.isEmpty) {
                    return const Center(child: Text('No journal entries yet.'));
                  }
                  final journalEntries = snapshot.data!.journalEntries;
                  return ListView.builder(
                    itemCount: journalEntries.length,
                    itemBuilder: (context, index) {
                      final entry = journalEntries[index];
                      // Display journal entry with timestamp
                      return ListTile(
                        title: Text(entry['text']),
                        subtitle: Text(_formatTimestamp(entry['timestamp'])),
                      );
                    },
                  );
                },
              ),
            ),
            if (_geminiResponse.isNotEmpty) // Display Gemini response if available
              Card(
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _geminiResponse,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
            ), // Added missing closing parenthesis for Expanded
            TextField(
              controller: _journalController,
              decoration: InputDecoration(
                hintText: 'Write your journal entry...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _saveJournalEntry(userService, userId),
                ),
              ),
              maxLines: null, // Allows for multiple lines
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _journalController.text.isNotEmpty
                  ? () => _getGeminiAssistance(
                        Provider.of<GeminiService>(context, listen: false), // Access GeminiService
                        _journalController.text,
                      )
                  : null, // Disable button if text field is empty
              child: const Text('Get Gemini Assistance'),
            ),

          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
}