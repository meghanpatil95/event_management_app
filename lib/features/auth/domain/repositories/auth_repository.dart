import '../entities/auth_session.dart';

/// Abstract repository for authentication operations.
///
/// Defines the contract for login, logout, and session persistence.
abstract class AuthRepository {
  /// Performs login with [email] and [password].
  ///
  /// Returns [AuthSession] on success. Persists session securely.
  /// Throws on invalid credentials or network failure.
  Future<AuthSession> login(String email, String password);

  /// Logs out the current user and clears stored session/tokens.
  Future<void> logout();

  /// Returns the currently stored session, if any.
  ///
  /// Used for session persistence on app start. Returns null if not logged in.
  Future<AuthSession?> getStoredSession();
}
