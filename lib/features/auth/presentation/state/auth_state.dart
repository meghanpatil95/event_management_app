import '../../domain/entities/auth_session.dart';

/// Represents the current authentication UI state.
sealed class AuthState {
  const AuthState();
}

/// Initial state before we've checked stored session.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading (e.g. checking session or logging in).
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated. [session] holds user and tokens.
class AuthAuthenticated extends AuthState {
  final AuthSession session;
  const AuthAuthenticated(this.session);
}

/// User is not authenticated (no session or logged out).
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An error occurred (e.g. login failed).
class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
