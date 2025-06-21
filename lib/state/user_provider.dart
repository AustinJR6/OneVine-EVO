import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import 'auth_providers.dart';
import 'firestore_providers.dart';
import 'functions_provider.dart';

final userServiceProvider = ChangeNotifierProvider<UserService>((ref) {
  final auth = ref.watch(authServiceProvider);
  final firestore = ref.watch(firestoreServiceProvider);
  final functions = ref.watch(functionsServiceProvider);
  return UserService(auth, firestore, functions);
});
