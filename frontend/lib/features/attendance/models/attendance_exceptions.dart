/// checkIn()에 오늘의 출석번호와 다른 코드를 넘겼을 때 던져지는 예외.
///
/// 백엔드에 실제 검증 API가 생기면 서버가 내려주는 에러 코드(예: 409
/// INVALID_ATTENDANCE_CODE)에 맞춰 이 예외를 그대로 재사용하거나 교체하면 된다.
class InvalidAttendanceCodeException implements Exception {
  const InvalidAttendanceCodeException();
}
