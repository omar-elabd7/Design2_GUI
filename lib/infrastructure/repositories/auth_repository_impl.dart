import '../../shared/repositories/auth_repository.dart';
import '../../shared/models/app_user.dart';
import '../../shared/dto/login_request_dto.dart';
import '../../shared/dto/login_response_dto.dart';
import '../data_sources/mock/mock_auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final MockAuthDataSource _mockDataSource;

  AuthRepositoryImpl(this._mockDataSource);

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) =>
      _mockDataSource.login(request);

  @override
  Future<void> logout() => _mockDataSource.logout();

  @override
  Future<AppUser?> getCurrentUser() => _mockDataSource.getCurrentUser();

  @override
  Future<void> updateCredits(String userId, double newCredits) =>
      _mockDataSource.updateCredits(userId, newCredits);
}
