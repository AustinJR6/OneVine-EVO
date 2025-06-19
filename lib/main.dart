import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Placeholder screens
class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login Screen'),
            ElevatedButton(
              onPressed: () async {
                // TODO: Implement actual login logic
                // For now, simulate a successful login
                // In a real app, you would use FirebaseAuth.instance.signInWithEmailAndPassword, etc.
                context.read(isLoggedInProvider).state = true;
              },
              child: const Text('Simulate Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Home Screen'),
            ElevatedButton(
              onPressed: () async {
                // TODO: Implement actual logout logic
                // For now, simulate a successful logout
                // In a real app, you would use FirebaseAuth.instance.signOut();
                context.read(isLoggedInProvider).state = false;
              },
              child: const Text('Simulate Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

// Riverpod provider for authentication state
final isLoggedInProvider = StateProvider<bool>((ref) {
  // Listen to Firebase Auth state changes
  final authStateChanges = FirebaseAuth.instance.authStateChanges();
  return authStateChanges.map((user) => user != null).initialData(FirebaseAuth.instance.currentUser != null).requireValue;
});


// GoRouter configuration
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
  redirect: (context, state) {
    final isLoggedIn = context.read(isLoggedInProvider).state;
    final isLoggingIn = state.location == '/login';

    // Redirect logic
    if (isLoggedIn && isLoggingIn) return '/home';
    if (!isLoggedIn && !isLoggingIn && state.location != '/') return '/login'; // Redirect to login if not logged in and not already on login
    return null;
  },
  // Set the initial location based on auth state
  initialLocation: FirebaseAuth.instance.currentUser != null ? '/home' : '/login',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget { // Changed to ConsumerWidget to access provider
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    final router = ref.watch(_router); // Watch the router provider

    return MaterialApp.router(
      title: 'OneVine',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
