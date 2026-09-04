import '../repositories/attendance_repository.dart';

/// "출석번호 입력" 다이얼로그의 확인 버튼이 호출하는 유스케이스.
/// code가 오늘의 출석번호와 다르면 InvalidAttendanceCodeException을 던진다.
class CheckInUseCase {
  CheckInUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<void> call(int clubId, String code) {
    return _repository.checkIn(clubId, code);
  }
}
