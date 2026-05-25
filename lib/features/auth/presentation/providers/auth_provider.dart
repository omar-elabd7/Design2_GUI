import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/app_user.dart';
import '../../../../shared/dto/login_request_dto.dart';
import '../../../../shared/messages/app_messages.dart';
import '../../../../infrastructure/dependency_injection/providers.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/logger_service.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.sessionToken,
  });

  final AppUser? user;
  final bool isLoading;
  final String? error;
  final String? sessionToken;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    String? sessionToken,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      sessionToken: sessionToken ?? this.sessionToken,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState());

  final Ref _ref;

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(authRepositoryProvider);
      final response = await repo.login(
        LoginRequestDto(username: username, password: password),
      );
      final orderRepo = _ref.read(orderRepositoryProvider);
      // In mock mode only — cache credits locally so the order repository
      // can deduct them client-side. In live mode the server manages credits.
      if (!kUseLiveBackend) {
        (orderRepo as dynamic).cacheUserCredits(
          response.user.id,
          response.user.credits,
        );
      }
      state = state.copyWith(
        user: response.user,
        sessionToken: response.sessionToken,
        isLoading: false,
      );

      // ── Announce session to backend/robot over WebSocket ──────────────────
      if (kUseLiveBackend) {
        final ws = _ref.read(webSocketClientProvider);
        ws.send(
          UserSessionMsg(
            userId: response.user.id,
            username: response.user.username,
            name: response.user.name,
            role: response.user.role.name,
            rfidCardId: response.user.rfidCardId,
            credits: response.user.credits,
            sessionToken: response.sessionToken,
          ).toMap(),
        );
      }

      logger.info('Login success: ${response.user.username}', tag: 'Auth');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      logger.error('Login failed', exception: e, tag: 'Auth');
    }
  }

  Future<void> logout() async {
    // Notify backend that session is ending before clearing local state
    if (kUseLiveBackend && state.user != null) {
      final user = state.user!;
      final token = state.sessionToken ?? '';
      final ws = _ref.read(webSocketClientProvider);
      ws.send(
        UserSessionMsg(
          userId: user.id,
          username: user.username,
          name: user.name,
          role: user.role.name,
          rfidCardId: user.rfidCardId,
          credits: user.credits,
          sessionToken: token,
          isLogout: true,
        ).toMap(),
      );
    }
    await _ref.read(authRepositoryProvider).logout();
    state = const AuthState();
    logger.info('Logged out', tag: 'Auth');
  }

  void updateCredits(double newCredits) {
    if (state.user == null) return;
    final updatedUser = state.user!.copyWith(credits: newCredits);
    state = state.copyWith(user: updatedUser);
    _ref.read(authRepositoryProvider).updateCredits(updatedUser.id, newCredits);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
