import 'dart:math';
import '../../../../core/network/api_exceptions.dart';
import '../dto/event_dto.dart';

/// Exception thrown when a network error occurs.
/*class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}*/

/// Exception thrown when an event is not found.
class EventNotFoundException implements Exception {
  final String eventId;
  EventNotFoundException(this.eventId);

  @override
  String toString() =>
      'EventNotFoundException: Event with id $eventId not found';
}

/// Exception thrown when registering for an event the user is already registered for.
class AlreadyRegisteredException implements Exception {
  final String eventId;
  AlreadyRegisteredException(this.eventId);

  @override
  String toString() =>
      'AlreadyRegisteredException: Already registered for event $eventId';
}

/// Exception thrown when the event has expired (date/time has passed).
class EventExpiredException implements Exception {
  final String eventId;
  EventExpiredException(this.eventId);

  @override
  String toString() => 'EventExpiredException: Event $eventId has expired';
}

/// Exception thrown when unregistering from an event the user is not registered for.
class NotRegisteredException implements Exception {
  final String eventId;
  NotRegisteredException(this.eventId);

  @override
  String toString() =>
      'NotRegisteredException: Not registered for event $eventId';
}

/// Remote data source for events.
///
/// This is a mock implementation that simulates network calls using Future.delayed.
/// It includes pagination support and basic error simulation.
abstract class EventRemoteDataSource {
  /// Fetches events with pagination support.
  ///
  /// [page] - The page number (1-indexed).
  /// [pageSize] - The number of items per page.
  /// Returns a list of [EventDto] objects.
  /// Throws [NetworkException] if the operation fails.
  Future<List<EventDto>> getEvents({int page = 1, int pageSize = 20});

  /// Fetches a single event by its ID.
  ///
  /// [eventId] - The unique identifier of the event.
  /// Returns the [EventDto] if found.
  /// Throws [EventNotFoundException] if the event is not found.
  /// Throws [NetworkException] if the operation fails.
  Future<EventDto> getEventById(String eventId);

  /// Registers the current user for an event.
  ///
  /// [eventId] - The unique identifier of the event to register for.
  /// Returns the updated [EventDto] with [isRegistered] set to true.
  /// Throws [EventNotFoundException] if the event is not found.
  /// Throws [AlreadyRegisteredException] if already registered for the event.
  /// Throws [EventExpiredException] if the event has expired.
  /// Throws [NetworkException] if the operation fails.
  Future<EventDto> registerForEvent(String eventId);

  /// Unregisters the current user from an event.
  ///
  /// [eventId] - The unique identifier of the event to unregister from.
  /// Returns the updated [EventDto] with [isRegistered] set to false.
  /// Throws [EventNotFoundException] if the event is not found.
  /// Throws [NotRegisteredException] if not registered for the event.
  /// Throws [EventExpiredException] if the event has expired.
  /// Throws [NetworkException] if the operation fails.
  Future<EventDto> unregisterFromEvent(String eventId);
}

/// Mock implementation of [EventRemoteDataSource].
class MockEventRemoteDataSource implements EventRemoteDataSource {
  final Random _random = Random();

  // Simulated error rate (0.0 to 1.0)
  final double errorRate;

  // Simulated network delay range in milliseconds
  final int minDelayMs;
  final int maxDelayMs;

  /// Creates a [MockEventRemoteDataSource] instance.
  ///
  /// [errorRate] - Probability of throwing an error (0.0 to 1.0). Default is 0.1 (10%).
  /// [minDelayMs] - Minimum network delay in milliseconds. Default is 300ms.
  /// [maxDelayMs] - Maximum network delay in milliseconds. Default is 1500ms.
  MockEventRemoteDataSource({
    this.errorRate = 0.1,
    this.minDelayMs = 300,
    this.maxDelayMs = 1500,
  });

  // Mock data storage
  final Map<String, EventDto> _events = {};

  @override
  Future<List<EventDto>> getEvents({int page = 1, int pageSize = 20}) async {
    await _simulateNetworkDelay();
    _simulateError();

    // Generate mock events if not already generated
    if (_events.isEmpty) {
      _generateMockEvents();
    }

    // Get all events and apply pagination
    final allEvents = _events.values.toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    if (startIndex >= allEvents.length) {
      return [];
    }

    return allEvents.sublist(
      startIndex,
      endIndex > allEvents.length ? allEvents.length : endIndex,
    );
  }

  @override
  Future<EventDto> getEventById(String eventId) async {
    await _simulateNetworkDelay();
    _simulateError();

    // Generate mock events if not already generated
    if (_events.isEmpty) {
      _generateMockEvents();
    }

    final event = _events[eventId];
    if (event == null) {
      throw EventNotFoundException(eventId);
    }

    return event;
  }

  @override
  Future<EventDto> registerForEvent(String eventId) async {
    await _simulateNetworkDelay();
    _simulateError();

    if (_events.isEmpty) {
      _generateMockEvents();
    }

    final event = _events[eventId];
    if (event == null) {
      throw EventNotFoundException(eventId);
    }

    final eventDateTime = DateTime.parse(event.dateTime);
    if (eventDateTime.isBefore(DateTime.now())) {
      throw EventExpiredException(eventId);
    }

    if (event.isRegistered) {
      throw AlreadyRegisteredException(eventId);
    }

    final updatedEvent = EventDto(
      id: event.id,
      title: event.title,
      description: event.description,
      dateTime: event.dateTime,
      location: event.location,
      status: event.status,
      isRegistered: true,
    );

    _events[eventId] = updatedEvent;
    return updatedEvent;
  }

  @override
  Future<EventDto> unregisterFromEvent(String eventId) async {
    await _simulateNetworkDelay();
    _simulateError();

    if (_events.isEmpty) {
      _generateMockEvents();
    }

    final event = _events[eventId];
    if (event == null) {
      throw EventNotFoundException(eventId);
    }

    final eventDateTime = DateTime.parse(event.dateTime);
    if (eventDateTime.isBefore(DateTime.now())) {
      final expiredEvent = EventDto(
        id: event.id,
        title: event.title,
        description: event.description,
        dateTime: event.dateTime,
        location: event.location,
        status: 'expired',
        isRegistered: false,
      );
      _events[eventId] = expiredEvent;
      throw EventExpiredException(eventId);
    }

    if (!event.isRegistered) {
      throw NotRegisteredException(eventId);
    }

    final updatedEvent = EventDto(
      id: event.id,
      title: event.title,
      description: event.description,
      dateTime: event.dateTime,
      location: event.location,
      status: event.status,
      isRegistered: false,
    );

    _events[eventId] = updatedEvent;
    return updatedEvent;
  }

  /// Simulates network delay using Future.delayed.
  Future<void> _simulateNetworkDelay() async {
    final delayMs = minDelayMs + _random.nextInt(maxDelayMs - minDelayMs);
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  /// Simulates random network errors based on error rate.
  void _simulateError() {
    if (_random.nextDouble() < errorRate) {
      final errorMessages = [
        'Network connection timeout',
        'Server error occurred',
        'Unable to reach server',
        'Request failed',
      ];
      throw NetworkException(
        errorMessages[_random.nextInt(errorMessages.length)],
      );
    }
  }

  /// Generates mock event data.
  void _generateMockEvents() {
    final now = DateTime.now();
    final locations = [
      'Conference Center',
      'Grand Ballroom',
      'Tech Hub',
      'Community Hall',
      'Exhibition Center',
      'City Park',
      'University Campus',
      'Hotel Convention Center',
    ];

    final titles = [
      'Tech Conference 2026',
      'Flutter Meetup',
      'Design Workshop',
      'Startup Pitch Night',
      'Networking Event',
      'Hackathon',
      'Product Launch',
      'Annual Summit',
      'Developer Day',
      'Innovation Forum',
      'AI Workshop',
      'Mobile Dev Conference',
      'Cloud Summit',
      'Data Science Meetup',
      'UI/UX Design Day',
    ];

    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 50; i++) {
      final eventId = 'event_${i + 1}';
      final daysOffset = _random.nextInt(60) - 10; // -10 to 50 days
      final eventDate = now.add(Duration(days: daysOffset));
      final eventDateOnly = DateTime(
        eventDate.year,
        eventDate.month,
        eventDate.day,
      );

      final status = eventDateOnly.isBefore(today)
          ? 'completed'
          : eventDateOnly.isAfter(today)
          ? 'upcoming'
          : 'ongoing';

      final event = EventDto(
        id: eventId,
        title: titles[_random.nextInt(titles.length)],
        description:
            'Join us for an exciting event featuring industry experts '
            'and networking opportunities. This is a detailed description of '
            'what attendees can expect.',
        dateTime: eventDate.toIso8601String(),
        location: locations[_random.nextInt(locations.length)],
        status: status,
        isRegistered: _random.nextBool(),
      );

      _events[eventId] = event;
    }
  }
}
