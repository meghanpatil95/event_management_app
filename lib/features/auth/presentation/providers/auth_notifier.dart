import 'package:event_management_app/core/network/api_client_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/domain.dart';
import '../state/auth_state.dart';
import 'auth_repository_provider.dart';

/// Notifier that holds auth state and restores session on startup.
///
/// - On [build], reads [AuthRepository.getStoredSession] for session persistence.
/// - [login] and [logout] update state and secure storage via repository.
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _restoreSession();
    return const AuthInitial();
  }

  Future<void> _restoreSession() async {
    state = const AuthLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final session = await repository.getStoredSession();
      if (session != null) {
        ref.read(apiClientProvider).setAccessToken(session.accessToken);
        state = AuthAuthenticated(session);
      } else {
        ref.read(apiClientProvider).setAccessToken(null);
        state = const AuthUnauthenticated();
      }
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  /// Performs login with [email] and [password].
  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final session = await repository.login(email, password);
      ref.read(apiClientProvider).setAccessToken(session.accessToken);
      state = AuthAuthenticated(session);
    } catch (e) {
      final message = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      state = AuthError(message);
    }
  }

  /// Logs out and clears session.
  Future<void> logout() async {
    state = const AuthLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.logout();
      ref.read(apiClientProvider).setAccessToken(null);
      state = const AuthUnauthenticated();
    } catch (_) {
      ref.read(apiClientProvider).setAccessToken(null);
      state = const AuthUnauthenticated();
    }
  }

  /// Clears any error state (e.g. after showing error to user).
  void clearError() {
    if (state is AuthError) {
      state = const AuthUnauthenticated();
    }
  }
}

/// Provider for auth state and actions.
final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
