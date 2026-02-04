import 'package:freezed_annotation/freezed_annotation.dart';

part 'event_registration_state.freezed.dart';

@freezed
class EventRegistrationState with _$EventRegistrationState {
  const factory EventRegistrationState({
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _EventRegistrationState;

  factory EventRegistrationState.initial() => const EventRegistrationState(
        isLoading: false,
      );
}
