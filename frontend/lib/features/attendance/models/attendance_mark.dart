/// 하루치 출석 표시 상태.
///
/// 백엔드 constant.AttendanceMark(PRESENT/ABSENT/VACATION/UPCOMING)와
/// 1:1로 매핑된다(openapi.yaml AttendanceMark 스키마, docs/API_CONTRACT.md
/// "5. 스터디 출석" 참고). AttendanceApiDataSourceImpl이 서버 응답을 파싱할
/// 때 [fromJson]을, 필요 시 [toJson]을 쓴다.
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

  static AttendanceMark fromJson(String value) {
    switch (value) {
      case 'PRESENT':
        return AttendanceMark.present;
      case 'ABSENT':
        return AttendanceMark.absent;
      case 'VACATION':
        return AttendanceMark.vacation;
      case 'UPCOMING':
        return AttendanceMark.upcoming;
      default:
        // 서버가 아직 모르는 새 값을 내려주더라도 화면이 죽지 않도록, 안전한
        // 쪽(아직 정해지지 않음)으로 방어한다.
        return AttendanceMark.upcoming;
    }
  }

  String toJson() => name.toUpperCase();
}
