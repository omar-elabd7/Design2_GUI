import '../../../shared/models/app_user.dart';
import '../../../shared/models/enums.dart';
import '../../../shared/dto/login_request_dto.dart';
import '../../../shared/dto/login_response_dto.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/utils/helpers.dart';

class MockAuthDataSource {
  final List<AppUser> _users = [
    AppUser(
      id: 'user_001',
      username: 'ahmed_hassan',
      passwordHash: Helpers.hashPassword('1234'),
      name: 'Ahmed Hassan',
      role: UserRole.customer,
      rfidCardId: 'RFID_A1B2C3',
      credits: 150.0,
    ),
    AppUser(
      id: 'user_002',
      username: 'sara',
      passwordHash: Helpers.hashPassword('5678'),
      name: 'Sara Mohamed',
      role: UserRole.customer,
      rfidCardId: 'RFID_D4E5F6',
      credits: 75.5,
    ),
    AppUser(
      id: 'user_003',
      username: 'worker1',
      passwordHash: Helpers.hashPassword('worker123'),
      name: 'Khaled Ibrahim',
      role: UserRole.worker,
      rfidCardId: 'RFID_W0K0R1',
      credits: 0.0,
    ),
    AppUser(
      id: 'user_004',
      username: 'ali',
      passwordHash: Helpers.hashPassword('pass123'),
      name: 'Ali Mahmoud',
      role: UserRole.customer,
      rfidCardId: 'RFID_G7H8I9',
      credits: 300.0,
    ),
    AppUser(
      id: 'user_005',
      username: 'shady',
      passwordHash: Helpers.hashPassword('12345678'),
      name: 'Shady',
      role: UserRole.customer,
      rfidCardId: 'RFID_SH4DY7',
      credits: 1000.0,
    ),
    AppUser(
      id: 'user_006',
      username: 'omar',
      passwordHash: Helpers.hashPassword('12345678'),
      name: 'Omar',
      role: UserRole.customer,
      rfidCardId: 'RFID_OM4R06',
      credits: 200.0,
    ),
    AppUser(
      id: 'user_007',
      username: 'ahmed',
      passwordHash: Helpers.hashPassword('12345678'),
      name: 'Ahmed',
      role: UserRole.worker,
      rfidCardId: 'RFID_AHM4D07',
      credits: 0.0,
    ),
  ];

  AppUser? _sessionUser;

  Future<LoginResponseDto> login(LoginRequestDto request) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final user = _users.firstWhere(
      (u) => u.username == request.username,
      orElse: () => throw const InvalidCredentialsException(),
    );

    if (!Helpers.verifyPassword(request.password, user.passwordHash)) {
      throw const InvalidCredentialsException();
    }

    _sessionUser = user;
    return LoginResponseDto(
      user: user,
      sessionToken: 'mock_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _sessionUser = null;
  }

  Future<AppUser?> getCurrentUser() async {
    return _sessionUser;
  }

  Future<void> updateCredits(String userId, double newCredits) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(credits: newCredits);
      if (_sessionUser?.id == userId) {
        _sessionUser = _users[index];
      }
    }
  }
}
