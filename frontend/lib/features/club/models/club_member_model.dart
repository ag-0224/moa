/// 동아리 멤버 목록(GET /clubs/{clubId}/members) 한 행. 관리자 권한 넘기기
/// 화면(TransferLeadershipPage)이 넘겨줄 대상을 고르는 데 쓴다.
class ClubMemberModel {
  const ClubMemberModel({
    required this.userId,
    required this.name,
    required this.isLeader,
  });

  final int userId;
  final String name;

  /// 이 멤버가 현재 동아리장인지 여부. 자기 자신(현재 로그인한 사용자)에게는
  /// 넘길 수 없으므로, 화면에서 이 값으로 후보 목록에서 제외한다.
  final bool isLeader;

  factory ClubMemberModel.fromJson(Map<String, dynamic> json) {
    return ClubMemberModel(
      userId: json['userId'] as int,
      name: json['name'] as String,
      isLeader: json['leader'] as bool? ?? false,
    );
  }
}
