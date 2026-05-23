import '../../../shared/dto/login_request_dto.dart';
import '../../../shared/dto/login_response_dto.dart';
import '../../../shared/models/app_user.dart';
import '../../../core/errors/app_exceptions.dart';

class AuthApiDataSource {
  AuthApiDataSource();

  Future<LoginResponseDto> login(LoginRequestDto request) async {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<void> logout() async {
    throw const NetworkException('Real backend not connected yet');
  }

  Future<AppUser?> getCurrentUser() async {
    return null;
  }

  Future<void> updateCredits(String userId, double newCredits) async {
    throw const NetworkException('Real backend not connected yet');
  }
}
