/// 하루치 출석 표시 상태.
///
/// 백엔드에 아직 출석 관련 API/스키마가 없어서(REPOSITORY_STRUCTURE.md,
/// API_CONTRACT.md에 미정의) 이 enum과 이 feature 전체는 우선 프론트엔드
/// Mock 데이터로만 동작한다. 실제 계약이 정해지면 $moa-change-api-contract
/// 절차(계약 문서 -> 백엔드 -> 프론트엔드 -> mock-data.json -> 테스트)를 따라
/// 이 enum을 서버 Enum과 맞추고 MockAttendanceDataSource를 실제 API
/// DataSource로 교체하면 된다.
enum AttendanceMark {
  /// 출석.
  present,

  /// 결석.
  absent,

  /// 휴가 처리됨(결석으로 집계하지 않음).
  vacation,

  /// 아직 오지 않은 날(이번 주의 미래 요일) 또는 아직 체크되지 않음.
  upcoming;

  bool get isPast => this == present || this == absent || this == vacation;
}
