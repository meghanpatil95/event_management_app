import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../domain/domain.dart';
import '../state/event_registration_state.dart';

/// [StateNotifier] for a single event's registration status.
///
/// Loads initial status, and supports register/unregister with loading
/// and error handling. Duplicate register is a no-op.
class EventRegistrationNotifier extends StateNotifier<EventRegistrationState> {
  EventRegistrationNotifier(this._repository)
    : super(EventRegistrationState.initial());

  final EventRepository _repository;

  /// Loads the current registration status for [eventId] from the repository
  /// (remote or local cache). Updates [isRegistered] accordingly.
  Future<void> loadInitialStatus(String eventId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final event = await _repository.getEventById(eventId);
      state = state.copyWith(
        isRegistered: event.isRegistered,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e, _) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Registers the current user for the event. No-op if already registered.
  Future<void> register(String eventId) async {
    if (state.isRegistered) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.registerForEvent(eventId);
      state = state.copyWith(
        isRegistered: true,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e, _) {
      state = state.copyWith(
        isLoading: false,
        isRegistered: state.isRegistered,
        errorMessage: 'Registration failed. Please try again.',
      );
    }
  }

  /// Unregisters the current user from the event. No-op if not registered.
  Future<void> unregister(String eventId) async {
    if (!state.isRegistered) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.unregisterFromEvent(eventId);
      state = state.copyWith(
        isRegistered: false,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e, _) {
      state = state.copyWith(
        isLoading: false,
        isRegistered: state.isRegistered,
        errorMessage: 'Unable to unregister. Please try again.',
      );
    }
  }
}
