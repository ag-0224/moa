import '../../user/models/user_model.dart';

/// openapi.yaml POST /auth/login 응답(LoginResponse) 스키마와 매핑된다.
class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.expiresInSeconds,
    required this.user,
  });

  final String accessToken;
  final int expiresInSeconds;
  final UserModel user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      expiresInSeconds: json['expiresInSeconds'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
