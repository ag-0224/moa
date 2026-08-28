import '../../../features/user/models/user_model.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final UserModel user;
}

/// 로그인은 성공했지만 아직 회원가입(추가 정보 입력)을 완료하지 않은 상태.
/// User.profileCompleted가 false일 때(닉네임 미입력) 여기로 온다.
class AuthNeedsSignUp extends AuthState {
  const AuthNeedsSignUp(this.user);

  final UserModel user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);

  final String message;
}
