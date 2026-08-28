import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../features/auth/repositories/entities/auth_provider_type.dart';
import '../../../features/auth/usecases/sign_in_use_case.dart';
import '../../../features/auth/usecases/sign_out_use_case.dart';
import '../../../features/user/models/user_model.dart';
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
      success: (user) => state = _stateFor(user),
      failure: (_) => state = const AuthUnauthenticated(),
    );
  }

  Future<void> signIn(AuthProviderType provider) async {
    state = const AuthLoading();
    final result = await _signInUseCase(provider);
    result.when(
      success: (user) => state = _stateFor(user),
      failure: (error) => state = AuthError(_messageOf(error)),
    );
  }

  /// 로그인 직후(signIn) 또는 세션 복원(_restoreSession) 직후 호출된다.
  /// user.profileCompleted(=닉네임 입력 여부)에 따라 메인 화면으로 보낼지
  /// 회원가입 화면(추가 정보 입력)으로 보낼지 결정한다.
  AuthState _stateFor(UserModel user) {
    return user.profileCompleted ? AuthAuthenticated(user) : AuthNeedsSignUp(user);
  }

  /// 회원가입 화면에서 '작성 완료' 제출이 성공했을 때 SignUpPage가 호출한다.
  /// signIn()과 달리 여기서 AuthLoading/AuthError를 거치지 않는다: 제출 실패는
  /// SignUpPage가 자신의 로컬 상태로 표시해야 하며(예: 닉네임 중복 에러를 입력
  /// 필드 아래에 표시), 전역 AuthState를 AuthError로 바꾸면 app.dart가 곧바로
  /// SignInPage로 화면을 튕겨버려 사용자가 입력하던 내용을 잃게 된다.
  void markProfileCompleted(UserModel user) {
    state = AuthAuthenticated(user);
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
