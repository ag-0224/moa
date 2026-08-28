/// backend ClubDetailResponse.applicationStatus(ClubApplicationStatus)와 매핑되는
/// 동아리 가입 신청 상태. joined가 true면 이 값은 항상 none이다.
enum ClubApplicationStatus {
  /// 아직 신청서를 낸 적 없음(서버 응답의 applicationStatus == null).
  none,

  /// 신청서를 냈고 동아리장 승인을 기다리는 중.
  pending,

  /// 거절됨. 다시 지원할 수 있다.
  rejected;

  static ClubApplicationStatus fromJson(String? value) {
    switch (value) {
      case 'PENDING':
        return ClubApplicationStatus.pending;
      case 'REJECTED':
        return ClubApplicationStatus.rejected;
      default:
        return ClubApplicationStatus.none;
    }
  }
}
