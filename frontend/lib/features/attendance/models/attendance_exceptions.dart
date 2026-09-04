/// checkIn()에 오늘의 출석번호와 다른 코드를 넘겼을 때 던져지는 예외.
/// 서버 에러 코드 409 INVALID_ATTENDANCE_CODE와 매핑된다
/// (AttendanceApiDataSourceImpl 참고).
class InvalidAttendanceCodeException implements Exception {
  const InvalidAttendanceCodeException();
}

/// checkIn()을 호출했는데 오늘 그 스터디의 출석번호 자체가 아직 발급되지
/// 않았을 때 던져지는 예외. 서버 에러 코드 404 ATTENDANCE_CODE_NOT_ISSUED와
/// 매핑된다. 관리 페이지의 "출석번호 확인" 화면은 아직 없어서(별도 이슈)
/// 로컬 개발 시드 데이터가 없는 스터디에서 발생할 수 있다.
class AttendanceCodeNotIssuedException implements Exception {
  const AttendanceCodeNotIssuedException();
}

/// useVacation()을 호출했는데 이번 학기 휴가를 이미 모두 썼을 때 던져지는
/// 예외. 서버 에러 코드 409 VACATION_LIMIT_EXCEEDED와 매핑된다.
/// CheckInButton은 보통 이 상황을 먼저 클라이언트에서 걸러서(overview의
/// myVacationDaysUsed/myVacationDaysTotal) 확인 대신 안내만 보여주므로,
/// 이 예외는 주로 동시 요청 같은 경쟁 상황에 대한 방어다.
class VacationLimitExceededException implements Exception {
  const VacationLimitExceededException();
}
