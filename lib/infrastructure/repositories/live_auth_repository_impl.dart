import '../../shared/repositories/auth_repository.dart';
import '../../shared/models/app_user.dart';
import '../../shared/dto/login_request_dto.dart';
import '../../shared/dto/login_response_dto.dart';
import '../data_sources/live/live_auth_data_source.dart';

class LiveAuthRepositoryImpl implements AuthRepository {
  final LiveAuthDataSource _dataSource;

  LiveAuthRepositoryImpl(this._dataSource);

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) =>
      _dataSource.login(request);

  @override
  Future<void> logout() => _dataSource.logout();

  @override
  Future<AppUser?> getCurrentUser() => _dataSource.getCurrentUser();

  @override
  Future<void> updateCredits(String userId, double newCredits) =>
      _dataSource.updateCredits(userId, newCredits);
}
