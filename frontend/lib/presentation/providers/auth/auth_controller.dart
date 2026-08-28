import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../features/auth/repositories/entities/auth_provider_type.dart';
import '../../../features/auth/usecases/sign_in_use_case.dart';
import '../../../features/auth/usecases/sign_out_use_case.dart';
import '../../../features/user/usecases/get_my_info_use_case.dart';
import '../di_providers.dart';
import 'auth_state.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.watch(signInUseCaseProvider),
    ref.watch(signOutUseCaseProvider),
    ref.watch(getMyInfoUseCaseProvider),
  );
});

/// 앱 전역 로그인 상태. 시작 시 저장된 토큰으로 GET /users/me를 호출해
/// 세션이 아직 유효한지 확인한다(자동 로그인).
class AuthController extends StateNotifier<AuthState> {
  AuthController(this._signInUseCase, this._signOutUseCase, this._getMyInfoUseCase)
      : super(const AuthInitial()) {
    _restoreSession();
  }

  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetMyInfoUseCase _getMyInfoUseCase;

  Future<void> _restoreSession() async {
    final result = await _getMyInfoUseCase();
    result.when(
      success: (user) => state = AuthAuthenticated(user),
      failure: (_) => state = const AuthUnauthenticated(),
    );
  }

  Future<void> signIn(AuthProviderType provider) async {
    state = const AuthLoading();
    final result = await _signInUseCase(provider);
    result.when(
      success: (user) => state = AuthAuthenticated(user),
      failure: (error) => state = AuthError(_messageOf(error)),
    );
  }

  Future<void> signOut() async {
    state = const AuthLoading();
    final result = await _signOutUseCase();
    result.when(
      success: (_) => state = const AuthUnauthenticated(),
      failure: (error) => state = AuthError(_messageOf(error)),
    );
  }

  String _messageOf(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return error.toString();
  }
}
