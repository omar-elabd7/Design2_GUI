import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../shared/dto/login_request_dto.dart';
import '../../../shared/dto/login_response_dto.dart';
import '../../../shared/models/app_user.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_exceptions.dart';

class LiveAuthDataSource {
  Future<LoginResponseDto> login(LoginRequestDto request) async {
    final res = await http
        .post(
          Uri.parse('$kBaseUrl$kLoginEndpoint'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(request.toMap()),
        )
        .timeout(kHttpTimeout);

    if (res.statusCode == 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      return LoginResponseDto.fromMap(map);
    }
    throw const AuthException('Invalid username or password');
  }

  Future<void> logout() async {}

  Future<AppUser?> getCurrentUser() async => null;

  Future<void> updateCredits(String userId, double newCredits) async {}
}
