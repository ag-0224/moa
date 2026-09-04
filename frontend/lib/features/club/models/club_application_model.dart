/// backend ClubApplicationResponse(ClubApplicationStatus)와 매핑되는 가입
/// 신청 승인/거절 상태. club_application_status.dart의 ClubApplicationStatus와
/// 다른 타입이다 — 그쪽은 "내가 신청한 상태"(null/PENDING/REJECTED)만 표현하는
/// 반면, 이쪽은 관리자 화면이 보는 신청서 자체의 상태(PENDING/APPROVED/REJECTED)라
/// 의미가 달라 섞지 않는다.
enum ClubApplicationReviewStatus {
  pending,
  approved,
  rejected;

  static ClubApplicationReviewStatus fromJson(String value) {
    switch (value) {
      case 'APPROVED':
        return ClubApplicationReviewStatus.approved;
      case 'REJECTED':
        return ClubApplicationReviewStatus.rejected;
      default:
        return ClubApplicationReviewStatus.pending;
    }
  }
}

/// 가입 신청 관리 화면(ClubApplicationsPage) 한 행. GET(목록)/POST(승인·거절)
/// /clubs/{clubId}/applications... 세 엔드포인트가 전부 이 모델로 응답한다.
class ClubApplicationModel {
  const ClubApplicationModel({
    required this.id,
    required this.userId,
    required this.applicantName,
    required this.selfIntroduction,
    required this.status,
    required this.appliedAt,
  });

  final int id;
  final int userId;
  final String applicantName;
  final String selfIntroduction;
  final ClubApplicationReviewStatus status;
  final DateTime appliedAt;

  factory ClubApplicationModel.fromJson(Map<String, dynamic> json) {
    return ClubApplicationModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      applicantName: json['applicantName'] as String,
      selfIntroduction: json['selfIntroduction'] as String,
      status: ClubApplicationReviewStatus.fromJson(json['status'] as String),
      appliedAt: DateTime.parse(json['appliedAt'] as String),
    );
  }
}
