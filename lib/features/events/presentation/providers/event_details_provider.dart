import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import 'event_repository_provider.dart';

/// Provider that fetches a single event by [eventId].
///
/// Exposes [AsyncValue<Event>] with loading, data, and error states.
/// Use with [Ref.watch] in [EventDetailsScreen] for reactive updates.
final eventDetailsProvider =
    FutureProvider.autoDispose.family<Event, String>((ref, eventId) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEventById(eventId);
});
