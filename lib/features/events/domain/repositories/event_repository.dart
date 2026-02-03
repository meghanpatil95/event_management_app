import '../entities/event.dart';

/// Abstract repository for event operations.
/// 
/// This defines the contract for event data operations in the domain layer.
/// Implementations should be provided in the data layer.
abstract class EventRepository {
  /// Fetches all events.
  /// 
  /// Returns a list of [Event] entities.
  /// Throws an exception if the operation fails.
  Future<List<Event>> getEvents();

  /// Fetches a page of events.
  /// 
  /// [page] - The page number (1-indexed).
  /// [pageSize] - The number of items per page.
  /// Returns a list of [Event] entities for the requested page.
  /// Throws an exception if the operation fails.
  Future<List<Event>> getEventsPage({
    int page = 1,
    int pageSize = 20,
  });

  /// Fetches a single event by its ID.
  /// 
  /// [eventId] - The unique identifier of the event.
  /// Returns the [Event] entity if found.
  /// Throws an exception if the event is not found or operation fails.
  Future<Event> getEventById(String eventId);

  /// Registers the current user for an event.
  /// 
  /// [eventId] - The unique identifier of the event to register for.
  /// Returns the updated [Event] entity with [isRegistered] set to true.
  /// Throws an exception if registration fails or event is not found.
  Future<Event> registerForEvent(String eventId);

  /// Unregisters the current user from an event.
  /// 
  /// [eventId] - The unique identifier of the event to unregister from.
  /// Returns the updated [Event] entity with [isRegistered] set to false.
  /// Throws an exception if unregistration fails or event is not found.
  Future<Event> unregisterFromEvent(String eventId);
}
