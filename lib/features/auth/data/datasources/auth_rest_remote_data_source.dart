import 'package:event_management_app/core/network/network.dart';

import '../dto/auth_response_dto.dart';
import 'auth_remote_data_source.dart';

/// REST implementation of [AuthRemoteDataSource].
///
/// Uses the centralized [ApiClient] for login and logout.
/// DTOs are parsed from JSON and mapped to domain in the repository.
class AuthRestRemoteDataSource implements AuthRemoteDataSource {
  final ApiClient _client;

  AuthRestRemoteDataSource(this._client);

  @override
  Future<AuthResponseDto> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw InvalidCredentialsException('Email and password are required');
    }

    try {
      final response = await _client.post(
        'auth/login',
        body: {'email': email.trim(), 'password': password},
      );

      if (response is! Map<String, dynamic>) {
        throw AuthNetworkException('Invalid login response');
      }

      return AuthResponseDto.fromJson(response);
    } on UnauthorizedException catch (e) {
      throw InvalidCredentialsException(e.message);
    } on ApiException catch (e) {
      if (e is NetworkException) {
        throw AuthNetworkException(e.message);
      }
      throw AuthNetworkException(e.message);
    }
  }

  @override
  Future<void> logout(String accessToken) async {
    _client.setAccessToken(accessToken);
    try {
      await _client.post('auth/logout');
    } on ApiException catch (e) {
      throw AuthNetworkException(e.message);
    } finally {
      _client.setAccessToken(null);
    }
  }
}
