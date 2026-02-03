import 'dart:math';

import '../dto/auth_response_dto.dart';
import '../dto/user_dto.dart';

/// Exception thrown when login credentials are invalid.
class InvalidCredentialsException implements Exception {
  final String message;
  InvalidCredentialsException([this.message = 'Invalid email or password']);

  @override
  String toString() => 'InvalidCredentialsException: $message';
}

/// Exception thrown when a network error occurs during auth.
class AuthNetworkException implements Exception {
  final String message;
  AuthNetworkException(this.message);

  @override
  String toString() => 'AuthNetworkException: $message';
}

/// Remote data source for authentication (login / logout).
///
/// Abstract contract; mock implementation simulates REST API with delay.
abstract class AuthRemoteDataSource {
  /// Performs login. Returns [AuthResponseDto] on success.
  /// Throws [InvalidCredentialsException] for bad credentials.
  /// Throws [AuthNetworkException] on network failure.
  Future<AuthResponseDto> login(String email, String password);

  /// Logs out on the server (e.g. invalidate token). Mock may no-op.
  Future<void> logout(String accessToken);
}

/// Mock implementation of [AuthRemoteDataSource].
///
/// Simulates network delay and validates a fixed set of credentials.
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  final Random _random = Random();
  final double errorRate;
  final int minDelayMs;
  final int maxDelayMs;

  MockAuthRemoteDataSource({
    this.errorRate = 0.0,
    this.minDelayMs = 200,
    this.maxDelayMs = 800,
  });

  // Mock accepted credentials (in real app, server validates)
  static const _mockEmail = 'user@example.com';
  static const _mockPassword = 'password123';

  @override
  Future<AuthResponseDto> login(String email, String password) async {
    await _simulateNetworkDelay();
    _simulateError();

    if (email.trim().isEmpty || password.isEmpty) {
      throw InvalidCredentialsException('Email and password are required');
    }
    if (email != _mockEmail || password != _mockPassword) {
      throw InvalidCredentialsException('Invalid email or password');
    }

    final expiresAt = DateTime.now().add(const Duration(hours: 24));
    return AuthResponseDto(
      user: const UserDto(
        id: 'user_1',
        email: _mockEmail,
        displayName: 'Demo User',
      ),
      accessToken: 'mock_jwt_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: expiresAt.toIso8601String(),
    );
  }

  @override
  Future<void> logout(String accessToken) async {
    await _simulateNetworkDelay();
    _simulateError();
    // Mock: server would invalidate token; here we just no-op
  }

  Future<void> _simulateNetworkDelay() async {
    final delayMs = minDelayMs + _random.nextInt(maxDelayMs - minDelayMs);
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  void _simulateError() {
    if (_random.nextDouble() < errorRate) {
      throw AuthNetworkException('Network error during auth');
    }
  }
}
