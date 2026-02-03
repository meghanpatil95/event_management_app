import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';
import 'api_client.dart';

final apiConfigProvider = Provider<ApiConfig>((ref) {
  return const ApiConfig();
});

/// Single shared [ApiClient] for all REST APIs (auth, events, chat).
/// Set token via [ApiClient.setAccessToken] after login; clear on logout.
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(apiConfigProvider);
  return ApiClient(baseUrl: config.baseUrl);
});
