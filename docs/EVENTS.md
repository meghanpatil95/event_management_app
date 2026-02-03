# Events Feature (Documentation)

Overview of the Events feature for the Event Management app. Feature-level notes live in `lib/features/events/EVENTS.md`.

## Summary
- **List:** Paginated event list with loading and error handling.
- **Details:** Single event view with date, location, description, and status.
- **Registration:** Register / unregister with repository-driven logic and UI that reacts to loading and errors.

## Event Registration
- **State:** Riverpod `StateNotifier` (`EventRegistrationNotifier` / `EventRegistrationState`).
- **Logic:** All registration actions go through `EventRepository` (register, unregister, initial status via `getEventById`).
- **UI:** Event details screen shows registration state, loading indicator on the action button, and SnackBar on errors.

## Key Files
| Layer      | Path |
|-----------|------|
| State     | `lib/features/events/presentation/state/event_registration_state.dart` |
| Notifier  | `lib/features/events/presentation/providers/event_registration_notifier.dart` |
| Provider  | `lib/features/events/presentation/providers/event_registration_provider.dart` |
| Repository| `lib/features/events/domain/repositories/event_repository.dart` |
| UI        | `lib/features/events/presentation/screens/event_details_screen.dart` |

## See Also
- [Architecture](ARCHITECTURE.md)
- [Events feature notes](../lib/features/events/EVENTS.md)
