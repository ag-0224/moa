/// openapi.yaml User 스키마와 매핑된다 (GET /users/me, PATCH /users/me,
/// POST /auth/login 응답에 포함).
///
/// nickname/major/studentId는 회원가입(추가 정보 입력)을 완료하기 전까지 null이다.
/// profileCompleted는 서버가 계산해서 내려주는 값으로(nickname != null과 동치),
/// AuthController가 메인 화면/회원가입 화면 중 어디로 보낼지 판단하는 데 그대로 쓴다.
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.nickname,
    this.major,
    this.studentId,
    this.profileCompleted = true,
  });

  final int id;
  final String email;
  final String name;
  final String role;
  final String? nickname;
  final String? major;
  final String? studentId;

  /// 기본값 true: 혹시 서버 응답에 이 필드가 누락돼도 기존 사용자를 회원가입
  /// 화면으로 잘못 돌려보내지 않도록 안전한 쪽(메인 화면 유지)으로 방어한다.
  final bool profileCompleted;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      nickname: json['nickname'] as String?,
      major: json['major'] as String?,
      studentId: json['studentId'] as String?,
      profileCompleted: json['profileCompleted'] as bool? ?? true,
    );
  }
}
