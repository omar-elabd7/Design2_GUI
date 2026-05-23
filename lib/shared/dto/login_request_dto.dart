class LoginRequestDto {
  const LoginRequestDto({required this.username, required this.password});

  final String username;
  final String password;

  Map<String, dynamic> toMap() {
    return {'username': username, 'password': password};
  }
}
