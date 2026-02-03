import 'user.dart';

/// Represents an authenticated session (user + tokens).
///
/// Stored securely and restored on app start for session persistence.
class AuthSession {
  /// The authenticated user
  final User user;

  /// Access token for API requests
  final String accessToken;

  /// Optional refresh token for obtaining new access tokens
  final String? refreshToken;

  /// When the access token expires (optional, for mock can be null)
  final DateTime? expiresAt;

  const AuthSession({
    required this.user,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  AuthSession copyWith({
    User? user,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthSession(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSession &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          accessToken == other.accessToken;

  @override
  int get hashCode => user.hashCode ^ accessToken.hashCode;

  @override
  String toString() =>
      'AuthSession{user: $user, accessToken: ***, refreshToken: ${refreshToken != null}}';
}
