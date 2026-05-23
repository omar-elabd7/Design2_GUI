import '../models/app_user.dart';
import '../dto/login_request_dto.dart';
import '../dto/login_response_dto.dart';

abstract interface class AuthRepository {
  Future<LoginResponseDto> login(LoginRequestDto request);
  Future<void> logout();
  Future<AppUser?> getCurrentUser();
  Future<void> updateCredits(String userId, double newCredits);
}
