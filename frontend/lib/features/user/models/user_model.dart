/// openapi.yaml User 스키마와 매핑된다 (GET /users/me, POST /auth/login 응답에 포함).
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  final int id;
  final String email;
  final String name;
  final String role;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }
}
