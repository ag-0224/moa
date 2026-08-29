import '../repositories/attendance_repository.dart';

/// "출석하기" 버튼이 호출하는 유스케이스.
class CheckInUseCase {
  CheckInUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<void> call(int clubId) {
    return _repository.checkIn(clubId);
  }
}
