import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../data/datasources/event_remote_data_source.dart';
import '../../domain/domain.dart';
import '../state/event_registration_state.dart';
import 'event_details_provider.dart';

/// [StateNotifier] for a single event's registration status.
///
/// Loads initial status, and supports register/unregister with loading
/// and error handling. Duplicate register is a no-op.
class EventRegistrationNotifier extends StateNotifier<EventRegistrationState> {
  EventRegistrationNotifier(this.ref, this._repository)
    : super(EventRegistrationState.initial());
  final Ref ref;
  final EventRepository _repository;

  /// Loads the current registration status for [eventId] from the repository
  /// (remote or local cache). Updates [isRegistered] accordingly.
  Future<void> loadInitialStatus(String eventId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final event = await _repository.getEventById(eventId);
      state = state.copyWith(isLoading: false, errorMessage: null);
    } catch (e, _) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Registers the current user for the event. No-op if already registered.
  Future<void> register(String eventId) async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.registerForEvent(eventId);
      state = state.copyWith(isLoading: false);
      ref.invalidate(eventDetailsProvider(eventId));
    } catch (e, _) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '${e.toString()}.',
      );
    }
  }

  /// Unregisters the current user from the event. No-op if not registered.
  Future<void> unregister(String eventId) async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.unregisterFromEvent(eventId);
      state = state.copyWith(isLoading: false);
      ref.invalidate(eventDetailsProvider(eventId));
    } catch (e, _stacktrace) {
      print("e :$e \n stacktrace $_stacktrace");
      state = state.copyWith(
        isLoading: false,
        errorMessage: '${e.toString()}',
      );
    }
  }
}
