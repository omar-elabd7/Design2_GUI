import '../../../../shared/dto/login_request_dto.dart';
import '../../../../shared/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._authRepository);
  final AuthRepository _authRepository;

  Future<void> call(String username, String password) async {
    await _authRepository.login(
      LoginRequestDto(username: username, password: password),
    );
  }
}
