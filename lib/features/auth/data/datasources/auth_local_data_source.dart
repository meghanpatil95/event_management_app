import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user.dart';
import '../dto/user_dto.dart';

/// Keys for secure storage. Kept in one place for consistency.
class AuthStorageKeys {
  static const accessToken = 'auth_access_token';
  static const refreshToken = 'auth_refresh_token';
  static const userJson = 'auth_user_json';
  static const expiresAt = 'auth_expires_at';
}

/// Local data source for persisting auth session securely.
///
/// Uses [FlutterSecureStorage] for token and user data (secure on device).
abstract class AuthLocalDataSource {
  /// Saves the session (tokens + user) for session persistence.
  Future<void> saveSession(AuthSession session);

  /// Returns the stored session, or null if none.
  Future<AuthSession?> getStoredSession();

  /// Clears all stored auth data (logout).
  Future<void> clearSession();
}

/// Secure storage-backed implementation of [AuthLocalDataSource].
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<void> saveSession(AuthSession session) async {
    final userDto = UserDto.fromDomain(session.user);
    await _storage.write(
      key: AuthStorageKeys.accessToken,
      value: session.accessToken,
    );
    if (session.refreshToken != null) {
      await _storage.write(
        key: AuthStorageKeys.refreshToken,
        value: session.refreshToken,
      );
    }
    await _storage.write(
      key: AuthStorageKeys.userJson,
      value: _encodeUserJson(userDto),
    );
    if (session.expiresAt != null) {
      await _storage.write(
        key: AuthStorageKeys.expiresAt,
        value: session.expiresAt!.toIso8601String(),
      );
    }
  }

  @override
  Future<AuthSession?> getStoredSession() async {
    final accessToken = await _storage.read(key: AuthStorageKeys.accessToken);
    if (accessToken == null || accessToken.isEmpty) return null;

    final userJson = await _storage.read(key: AuthStorageKeys.userJson);
    if (userJson == null || userJson.isEmpty) return null;

    final user = _decodeUserJson(userJson);
    if (user == null) return null;

    final refreshToken =
        await _storage.read(key: AuthStorageKeys.refreshToken);
    final expiresAtStr = await _storage.read(key: AuthStorageKeys.expiresAt);
    final expiresAt = expiresAtStr != null
        ? DateTime.tryParse(expiresAtStr)
        : null;

    return AuthSession(
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  @override
  Future<void> clearSession() async {
    await _storage.delete(key: AuthStorageKeys.accessToken);
    await _storage.delete(key: AuthStorageKeys.refreshToken);
    await _storage.delete(key: AuthStorageKeys.userJson);
    await _storage.delete(key: AuthStorageKeys.expiresAt);
  }

  static String _encodeUserJson(UserDto dto) {
    final map = dto.toJson();
    return '${map['id']}|${map['email']}|${map['displayName']}';
  }

  static User? _decodeUserJson(String encoded) {
    try {
      final parts = encoded.split('|');
      if (parts.length < 3) return null;
      final userDto = UserDto(
        id: parts[0],
        email: parts[1],
        displayName: parts[2],
      );
      return userDto.toDomain();
    } catch (_) {
      return null;
    }
  }
}
