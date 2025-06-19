import 'package:flutter/material.dart';
import 'package:onevine/services/user_service.dart'; // Assuming UserService is needed
import 'package:provider/provider.dart'; // Assuming Provider is used for state management
import 'package:onevine/screens/home_screen.dart'; // Assuming HomeScreen is the next screen

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context); // Access UserService

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to OneVine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Welcome to OneVine!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Embark on a journey of spiritual reflection and growth.',
              style: TextStyle(fontSize: 24),
            ),
            // Add your onboarding content here
          ],
        ),
      ),
    );
  }
}