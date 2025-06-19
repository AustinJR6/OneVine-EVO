import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/functions_service.dart';

final functionsServiceProvider = Provider<FunctionsService>((ref) {
  return FunctionsService();
});
