import 'package:flutter/material.dart';
import '../services/gemini_service.dart'; // Assuming your GeminiService is here

class ReligionAIScreen extends StatefulWidget {
  const ReligionAIScreen({super.key});

  @override
  _ReligionAIScreenState createState() => _ReligionAIScreenState();
}

class _ReligionAIScreenState extends State<ReligionAIScreen> {
  final TextEditingController _promptController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  String _geminiResponse = '';
  bool _isLoading = false;

  void _getGeminiPrompt() async {
    setState(() {
      _isLoading = true;
      _geminiResponse = ''; // Clear previous response
    });

    final userPrompt = _promptController.text;
    if (userPrompt.isEmpty) {
      setState(() {
        _geminiResponse = 'Please enter a topic or question.';
        _isLoading = false;
      });
      return;
    }

    // TODO: Implement actual Gemini API call using _geminiService
    // For now, simulate a response
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call delay
    final simulatedResponse = "Reflect on the meaning of patience in times of hardship."; // Placeholder response

    setState(() {
      _geminiResponse = simulatedResponse; // Display Gemini's response
      _isLoading = false;
    });

    // In a real scenario, you would call:
    // try {
    //   final response = await _geminiService.getSpiritualReflection(userPrompt);
    //   setState(() {
    //     _geminiResponse = response;
    //     _isLoading = false;
    //   });
    // } catch (e) {
    //   setState(() {
    //     _geminiResponse = 'Error getting reflection: ${e.toString()}';
    //     _isLoading = false;
    //   });
    // }
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spiritual Reflection (AI)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Get a spiritual reflection prompt from our AI:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(
                hintText: 'Enter a topic (e.g., gratitude, forgiveness)',
                border: OutlineInputBorder(),
              ),
              maxLines: null,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _getGeminiPrompt,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Get Prompt'),
            ),
            const SizedBox(height: 16.0),
            if (_geminiResponse.isNotEmpty)
              Expanded(
                child: Card(
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Text(
                        _geminiResponse,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}