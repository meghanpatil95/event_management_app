import '../../domain/entities/auth_session.dart';
import 'user_dto.dart';

/// DTO for login/refresh API response (user + tokens).
class AuthResponseDto {
  final UserDto user;
  final String accessToken;
  final String? refreshToken;
  final String? expiresAt;

  const AuthResponseDto({
    required this.user,
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      user: UserDto.fromJson(Map<String, dynamic>.from(json['user'] as Map)),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: json['expiresAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt,
    };
  }

  AuthSession toDomain() {
    return AuthSession(
      user: user.toDomain(),
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt:
          expiresAt != null ? DateTime.tryParse(expiresAt!) : null,
    );
  }
}
