import '../../domain/entities/user.dart';

/// Data Transfer Object for User.
class UserDto {
  final String id;
  final String email;
  final String displayName;

  const UserDto({
    required this.id,
    required this.email,
    required this.displayName,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String? ?? json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
    };
  }

  User toDomain() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
    );
  }

  factory UserDto.fromDomain(User user) {
    return UserDto(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
    );
  }
}
