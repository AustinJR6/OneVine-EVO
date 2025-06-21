import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/confessional_screen.dart';
import 'screens/trivia_screen.dart';
import 'screens/organizations_screen.dart';
import 'screens/buy_tokens_screen.dart';
import 'screens/upgrade_screen.dart';
import 'screens/give_back_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/leaderboards_screen.dart';
import 'screens/submit_proof_screen.dart';
import 'screens/organization_management_screen.dart';
import 'screens/join_organization_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/forgot_username_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/select_religion_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/quote_screen.dart';
import 'state/auth_providers.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return GoRouter(
    refreshListenable: GoRouterRefreshStream(authState.asStream()),
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/confessional', builder: (c, s) => const ConfessionalScreen()),
      GoRoute(path: '/trivia', builder: (c, s) => const TriviaScreen()),
      GoRoute(path: '/organizations', builder: (c, s) => const OrganizationsScreen()),
      GoRoute(path: '/buyTokens', builder: (c, s) => const BuyTokensScreen()),
      GoRoute(path: '/upgrade', builder: (c, s) => const UpgradeScreen()),
      GoRoute(path: '/giveBack', builder: (c, s) => const GiveBackScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/leaderboards', builder: (c, s) => const LeaderboardsScreen()),
      GoRoute(path: '/submitProof', builder: (c, s) => const SubmitProofScreen()),
      GoRoute(path: '/organizationManagement', builder: (c, s) => const OrganizationManagementScreen()),
      GoRoute(path: '/joinOrganization', builder: (c, s) => const JoinOrganizationScreen()),
      GoRoute(path: '/forgotPassword', builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(path: '/forgotUsername', builder: (c, s) => const ForgotUsernameScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/selectReligion', builder: (c, s) => const SelectReligionScreen()),
      GoRoute(path: '/welcome', builder: (c, s) => const WelcomeScreen()),
      GoRoute(path: '/quote', builder: (c, s) => const QuoteScreen()),
    ],
    redirect: (context, state) {
      final loggedIn = ref.read(currentUserProvider) != null;
      final loggingIn = state.location == '/login';
      if (!loggedIn) return loggingIn ? null : '/login';
      if (loggingIn) return '/home';
      return null;
    },
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget { // Changed to ConsumerWidget to access provider
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    final router = ref.watch(routerProvider); // Watch the router provider

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
