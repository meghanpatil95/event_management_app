import 'dart:math';

import '../../../../core/mock/mock_event_status_overrides.dart';
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
/*
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

    final sub = allEvents.sublist(
      startIndex,
      endIndex > allEvents.length ? allEvents.length : endIndex,
    );
    return sub.map(_applyStatusOverride).toList();
  }

  EventDto _applyStatusOverride(EventDto e) {
    final over = mockEventStatusOverrides[e.id];
    if (over == null) return e;
    return EventDto(
      id: e.id,
      title: e.title,
      description: e.description,
      dateTime: e.dateTime,
      location: e.location,
      latitude: e.latitude,
      longitude: e.longitude,
      status: over,
      isRegistered: e.isRegistered,
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

    return _applyStatusOverride(event);
  }

  @override
  Future<EventDto> registerForEvent(String eventId) async {
    // await _simulateNetworkDelay();
    // _simulateError();
    print("_events : ${_events.isEmpty}");
    if (_events.isEmpty) {
      _generateMockEvents();
    }

    final event = _events[eventId];
    print("event 11 : ${event?.toJson()}");

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
      latitude: event.latitude,
      longitude: event.longitude,
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
        latitude: event.latitude,
        longitude: event.longitude,
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
      latitude: event.latitude,
      longitude: event.longitude,
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
*/


///
///

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

    final sub = allEvents.sublist(
      startIndex,
      endIndex > allEvents.length ? allEvents.length : endIndex,
    );
    return sub.map(_applyStatusOverride).toList();
  }

  EventDto _applyStatusOverride(EventDto e) {
    final over = mockEventStatusOverrides[e.id];
    if (over == null) return e;
    return EventDto(
      id: e.id,
      title: e.title,
      description: e.description,
      dateTime: e.dateTime,
      location: e.location,
      latitude: e.latitude,
      longitude: e.longitude,
      status: over,
      isRegistered: e.isRegistered,
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

    return _applyStatusOverride(event);
  }

  @override
  Future<EventDto> registerForEvent(String eventId) async {
    // await _simulateNetworkDelay();
    // _simulateError();
    print("_events : ${_events.isEmpty}");
    if (_events.isEmpty) {
      _generateMockEvents();
    }

    final event = _events[eventId];
    print("event 11 : ${event?.toJson()}");

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
      latitude: event.latitude,
      longitude: event.longitude,
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
        latitude: event.latitude,
        longitude: event.longitude,
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
      latitude: event.latitude,
      longitude: event.longitude,
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

  /// Mock coordinates per venue for map display (San Francisco area).
  /*  static const Map<String, ({double lat, double lng})> _locationCoordinates = {
    'Conference Center': (lat: 37.7849, lng: -122.4094),
    'Grand Ballroom': (lat: 37.7870, lng: -122.4010),
    'Tech Hub': (lat: 37.7749, lng: -122.4194),
    'Community Hall': (lat: 37.7699, lng: -122.4264),
    'Exhibition Center': (lat: 37.7895, lng: -122.4018),
    'City Park': (lat: 37.7694, lng: -122.4862),
    'University Campus': (lat: 37.8719, lng: -122.2585),
    'Hotel Convention Center': (lat: 37.7853, lng: -122.4086),
  };*/

  /// Mock coordinates per venue for map display (India).
  static const Map<String, ({double lat, double lng})> _locationCoordinates = {
    // Bengaluru
    'Bangalore Convention Center': (lat: 12.972442, lng: 77.580643),
    'Tech Park Whitefield': (lat: 12.969819, lng: 77.749972),

    // Mumbai
    'Mumbai Exhibition Centre': (lat: 19.162206, lng: 72.937422),
    'BKC Business Hub': (lat: 19.060722, lng: 72.869777),

    // Delhi / NCR
    'Pragati Maidan': (lat: 28.612912, lng: 77.234721),
    'Gurugram Cyber City': (lat: 28.494644, lng: 77.089558),

    // Hyderabad
    'HITEX Exhibition Center': (lat: 17.469972, lng: 78.376017),
    'Hitech City': (lat: 17.447412, lng: 78.376230),

    // Chennai
    'Chennai Trade Centre': (lat: 13.010978, lng: 80.205538),
    'OMR IT Corridor': (lat: 12.840640, lng: 80.153380),

    // Pune
    'Hinjewadi IT Park': (lat: 18.591271, lng: 73.738899),
    'Pune Convention Centre': (lat: 18.536208, lng: 73.893974),

    // Kolkata
    'Biswa Bangla Convention Centre': (lat: 22.580536, lng: 88.459431),

    // Ahmedabad
    'GIFT City': (lat: 23.161787, lng: 72.683516),
  };

  /// Generates mock event data with correct status logic.
  /*void _generateMockEvents() {
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

    for (int i = 0; i < 50; i++) {
      final eventId = 'event_${i + 1}';

      // Generate random date offset (-10 to +50 days)
      final daysOffset = _random.nextInt(60) - 10;

      // Generate random hour (8 AM to 8 PM)
      final hour = 8 + _random.nextInt(13);

      // Create event date with specific time
      final eventDate = DateTime(
        now.year,
        now.month,
        now.day + daysOffset,
        hour,
        0, // minutes
        0, // seconds
      );

      //  FIXED: Compare full DateTime, not just date
      final status = _getEventStatus(eventDate, now);
      final locationName = locations[_random.nextInt(locations.length)];
      final coords = _locationCoordinates[locationName];

      final event = EventDto(
        id: eventId,
        title: titles[_random.nextInt(titles.length)],
        description:
        'Join us for an exciting event featuring industry experts '
            'and networking opportunities. This is a detailed description of '
            'what attendees can expect.',
        dateTime: eventDate.toIso8601String(),
        location: locationName,
        latitude: coords?.lat,
        longitude: coords?.lng,
        status: status,
        isRegistered: _random.nextBool(),
      );

      _events[eventId] = event;
    }
  }*/

  void _generateMockEvents() {
    final now = DateTime.now();

    //  Always sync locations with lat/long map
    final locations = _locationCoordinates.keys.toList();

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

    for (int i = 0; i < 50; i++) {
      final eventId = 'event_${i + 1}';

      // Random date offset (-10 to +50 days)
      final daysOffset = _random.nextInt(60) - 10;

      // Random hour (8 AM to 8 PM)
      final hour = 8 + _random.nextInt(13);

      final eventDate = DateTime(
        now.year,
        now.month,
        now.day + daysOffset,
        hour,
      );

      final status = _getEventStatus(eventDate, now);

      //  Location ALWAYS exists in map
      final locationName = locations[_random.nextInt(locations.length)];
      final coords = _locationCoordinates[locationName]!;

      final event = EventDto(
        id: eventId,
        title: titles[_random.nextInt(titles.length)],
        description:
            'Join us for an exciting event featuring industry experts '
            'and networking opportunities. This is a detailed description of '
            'what attendees can expect.',
        dateTime: eventDate.toIso8601String(),
        location: locationName,
        latitude: coords.lat,
        longitude: coords.lng,
        status: status,
        isRegistered: _random.nextBool(),
      );

      _events[eventId] = event;
    }
  }

  /// Determines the correct event status based on event date/time and current time.
  ///
  /// Logic:
  /// - If event date/time is in the past → 'completed'
  /// - If event is today and within 2 hours → 'ongoing'
  /// - If event is in the future → 'upcoming'
  String _getEventStatus(DateTime eventDateTime, DateTime now) {
    // Event has already passed
    if (eventDateTime.isBefore(now)) {
      return 'completed';
    }

    // Check if event is happening today
    final eventDateOnly = DateTime(
      eventDateTime.year,
      eventDateTime.month,
      eventDateTime.day,
    );
    final todayDateOnly = DateTime(now.year, now.month, now.day);

    // If event is today
    if (eventDateOnly.isAtSameMomentAs(todayDateOnly)) {
      final timeDifference = eventDateTime.difference(now);

      // Event starts within 2 hours or has started but not ended (assuming 2-hour duration)
      if (timeDifference.inHours <= 2 && timeDifference.inHours >= -2) {
        return 'ongoing';
      }

      // Event is later today
      if (timeDifference.inHours > 2) {
        return 'upcoming';
      }

      // Event already finished today
      return 'completed';
    }

    // Event is in the future
    return 'upcoming';
  }
}
