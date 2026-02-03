import 'package:event_management_app/core/network/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/api_config.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

/// Provider for [EventRepository] injection.
///
/// Uses [EventRepositoryImpl] with [EventRestRemoteDataSource] (REST API)
/// and local cache for offline support.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final remoteDataSource = ApiConfig.useMockApi ? MockEventRemoteDataSource() : EventRestRemoteDataSource(client);
  final localDataSource = EventLocalDataSourceImpl();
  return EventRepositoryImpl(remoteDataSource, localDataSource);
});
