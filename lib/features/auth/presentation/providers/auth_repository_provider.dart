import 'package:event_management_app/core/network/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/api_config.dart';
import '../../data/data.dart';
import '../../domain/domain.dart';

/// Provider for [AuthRepository] injection.
///
/// Uses [AuthRepositoryImpl] with [AuthRestRemoteDataSource] (REST API)
/// and [AuthLocalDataSourceImpl] (secure storage) for session persistence.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final remote = ApiConfig.useMockApi ? MockAuthRemoteDataSource() : AuthRestRemoteDataSource(client);
  final local = AuthLocalDataSourceImpl();
  return AuthRepositoryImpl(remote, local);
});
