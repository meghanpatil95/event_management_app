import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/event_registration_state.dart';
import 'event_registration_notifier.dart';
import 'event_repository_provider.dart';

/// [StateNotifierProvider.family] for event registration state by [eventId].
///
/// Injects [EventRepository] from [eventRepositoryProvider].
/// Use [ref.watch(eventRegistrationProvider(eventId))] for state,
/// [ref.read(eventRegistrationProvider(eventId).notifier)] for actions.
final eventRegistrationProvider =
    StateNotifierProvider.family<
      EventRegistrationNotifier,
      EventRegistrationState,
      String
    >((ref, eventId) {
      final repository = ref.watch(eventRepositoryProvider);
      return EventRegistrationNotifier(repository);
    });
