/// Event entity representing an event in the domain layer.
/// 
/// This is a pure Dart class with no Flutter or JSON dependencies.
class Event {
  /// Unique identifier for the event
  final String id;

  /// Title of the event
  final String title;

  /// Description of the event
  final String description;

  /// Date and time when the event occurs
  final DateTime dateTime;

  /// Location where the event takes place
  final String location;

  /// Current status of the event
  final EventStatus status;

  /// Whether the current user is registered for this event
  final bool isRegistered;

  /// Creates an [Event] instance.
  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.status,
    required this.isRegistered,
  });

  /// Whether the event has ended (registration no longer available).
  bool get isExpired => status == EventStatus.completed;

  /// Creates a copy of this event with the given fields replaced with new values.
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dateTime,
    String? location,
    EventStatus? status,
    bool? isRegistered,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      location: location ?? this.location,
      status: status ?? this.status,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          dateTime == other.dateTime &&
          location == other.location &&
          status == other.status &&
          isRegistered == other.isRegistered;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      description.hashCode ^
      dateTime.hashCode ^
      location.hashCode ^
      status.hashCode ^
      isRegistered.hashCode;

  @override
  String toString() {
    return 'Event{id: $id, title: $title, description: $description, '
        'dateTime: $dateTime, location: $location, status: $status, '
        'isRegistered: $isRegistered}';
  }
}

/// Status of an event
enum EventStatus {
  /// Event is upcoming and open for registration
  upcoming,

  /// Event is currently happening
  ongoing,

  /// Event has ended
  completed,

  /// Event has been cancelled
  cancelled,
}
