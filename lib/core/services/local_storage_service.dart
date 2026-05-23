import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _sessionTokenKey = 'session_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<void> saveSession({
    required String token,
    required String userId,
    required String role,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_sessionTokenKey, token);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userRoleKey, role);
  }

  Future<void> clearSession() async {
    final prefs = await _prefs;
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
  }

  Future<String?> getSessionToken() async {
    final prefs = await _prefs;
    return prefs.getString(_sessionTokenKey);
  }

  Future<String?> getSavedUserId() async {
    final prefs = await _prefs;
    return prefs.getString(_userIdKey);
  }

  Future<String?> getSavedUserRole() async {
    final prefs = await _prefs;
    return prefs.getString(_userRoleKey);
  }

  Future<bool> hasActiveSession() async {
    final token = await getSessionToken();
    return token != null && token.isNotEmpty;
  }
}
