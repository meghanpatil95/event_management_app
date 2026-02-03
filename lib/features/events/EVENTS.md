# Events Feature

## Responsibilities
- Fetch and display upcoming events
- Support pagination
- Show event details
- Handle registration state (register / unregister)

## Data Sources
- Mock REST API for events
- Mock socket for live updates

## Event Registration
- **State:** Managed via Riverpod `StateNotifier` (`EventRegistrationNotifier` + `EventRegistrationState`).
- **Logic:** Repository-driven; notifier calls `EventRepository.registerForEvent` / `unregisterFromEvent` and `getEventById` for initial status.
- **UI:** Event details screen reacts to:
  - **Registration:** “You are registered” and Register / Unregister button.
  - **Loading:** Button shows a spinner and is disabled.
  - **Error:** SnackBar on failure; errors cleared when a new action starts.
- **Provider:** `eventRegistrationProvider(eventId)` — use `.notifier` for `loadInitialStatus`, `register`, `unregister`.

## Edge Cases
- Empty event list
- Expired events (register button disabled)
- Network failure
- Duplicate registrations (no-op when already registered)
