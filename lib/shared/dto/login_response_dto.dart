import '../models/app_user.dart';

class LoginResponseDto {
  const LoginResponseDto({required this.user, required this.sessionToken});

  final AppUser user;
  final String sessionToken;

  factory LoginResponseDto.fromMap(Map<String, dynamic> map) {
    return LoginResponseDto(
      user: AppUser.fromMap(map['user'] as Map<String, dynamic>),
      sessionToken: map['session_token'] as String,
    );
  }
}
