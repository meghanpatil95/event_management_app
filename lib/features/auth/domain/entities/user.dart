/// User entity representing an authenticated user in the domain layer.
///
/// This is a pure Dart class with no Flutter or JSON dependencies.
class User {
  /// Unique identifier for the user
  final String id;

  /// User's email address
  final String email;

  /// Display name
  final String displayName;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          displayName == other.displayName;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ displayName.hashCode;

  @override
  String toString() => 'User{id: $id, email: $email, displayName: $displayName}';
}
