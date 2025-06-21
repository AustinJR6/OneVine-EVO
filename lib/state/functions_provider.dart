import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/functions_service.dart';
import 'http_provider.dart';

final functionsServiceProvider = Provider<FunctionsService>((ref) {
  final httpService = ref.watch(httpServiceProvider);
  return FunctionsService(httpService);
});
