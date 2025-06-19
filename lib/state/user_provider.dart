import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';

final userServiceProvider = ChangeNotifierProvider<UserService>((ref) {
  return UserService();
});
