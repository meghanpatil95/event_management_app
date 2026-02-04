import 'package:event_management_app/core/config/api_config.dart';
import 'package:event_management_app/core/network/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';

/// Provider for [ChatRepository]. Uses mock chat data when [ApiConfig.useMockApi],
/// with Hive local persistence for sent/cached messages.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final remote = ApiConfig.useMockApi
      ? MockChatRemoteDataSource()
      : ChatRestRemoteDataSource(ref.watch(apiClientProvider));
  final local = ChatLocalDataSourceImpl();
  return ChatRepositoryImpl(remote, local);
});
