import '../repositories/attendance_repository.dart';

/// "휴가 사용" 다이얼로그에서 확정했을 때 호출하는 유스케이스.
class UseVacationUseCase {
  UseVacationUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<void> call(int clubId) {
    return _repository.useVacation(clubId);
  }
}
