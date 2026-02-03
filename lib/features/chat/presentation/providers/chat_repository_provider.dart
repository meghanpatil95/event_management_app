import 'package:event_management_app/core/network/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';

/// Provider for [ChatRepository] (REST API + DTO to domain mapping).
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final remote = ChatRestRemoteDataSource(client);
  return ChatRepositoryImpl(remote);
});
