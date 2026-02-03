import '../../domain/entities/event.dart';

/// Data Transfer Object for Event.
/// 
/// Used to serialize/deserialize Event data from/to JSON.
class EventDto {
  /// Unique identifier for the event
  final String id;

  /// Title of the event
  final String title;

  /// Description of the event
  final String description;

  /// Date and time when the event occurs (ISO 8601 string)
  final String dateTime;

  /// Location where the event takes place
  final String location;

  /// Current status of the event (string representation)
  final String status;

  /// Whether the current user is registered for this event
  final bool isRegistered;

  /// Creates an [EventDto] instance.
  const EventDto({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.status,
    required this.isRegistered,
  });

  /// Creates an [EventDto] from a JSON map.
  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dateTime: json['dateTime'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      isRegistered: json['isRegistered'] as bool? ?? false,
    );
  }

  /// Converts this [EventDto] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dateTime': dateTime,
      'location': location,
      'status': status,
      'isRegistered': isRegistered,
    };
  }

  /// Converts this [EventDto] to a domain [Event] entity.
  Event toDomain() {
    return Event(
      id: id,
      title: title,
      description: description,
      dateTime: DateTime.parse(dateTime),
      location: location,
      status: _parseStatus(status),
      isRegistered: isRegistered,
    );
  }

  /// Creates an [EventDto] from a domain [Event] entity.
  factory EventDto.fromDomain(Event event) {
    return EventDto(
      id: event.id,
      title: event.title,
      description: event.description,
      dateTime: event.dateTime.toIso8601String(),
      location: event.location,
      status: _statusToString(event.status),
      isRegistered: event.isRegistered,
    );
  }

  /// Parses a status string to [EventStatus] enum.
  static EventStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return EventStatus.upcoming;
      case 'ongoing':
        return EventStatus.ongoing;
      case 'completed':
        return EventStatus.completed;
      case 'cancelled':
        return EventStatus.cancelled;
      case 'expired':
        return EventStatus.expired;
      default:
        return EventStatus.upcoming;
    }
  }

  /// Converts [EventStatus] enum to string.
  static String _statusToString(EventStatus status) {
    switch (status) {
      case EventStatus.upcoming:
        return 'upcoming';
      case EventStatus.ongoing:
        return 'ongoing';
      case EventStatus.completed:
        return 'completed';
      case EventStatus.cancelled:
        return 'cancelled';
      case EventStatus.expired:
        return 'expired';
    }
  }
}
