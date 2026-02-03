import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/data.dart';
import '../../domain/domain.dart';

/// Provider for [EventRepository] injection.
///
/// Supplies the application with an [EventRepository] implementation.
/// Uses [EventRepositoryImpl] with [MockEventRemoteDataSource] by default.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final remoteDataSource = MockEventRemoteDataSource(
    errorRate: 0.0,
    minDelayMs: 200,
    maxDelayMs: 800,
  );
  final localDataSource = EventLocalDataSourceImpl();
  return EventRepositoryImpl(remoteDataSource, localDataSource);
});
