import '../models/attendance_code_model.dart';
import '../repositories/attendance_repository.dart';

/// 스터디 관리 페이지 "출석번호 확인" 화면(StudyAttendanceCodePage)이 쓰는
/// 유스케이스.
class GetTodayAttendanceCodeUseCase {
  GetTodayAttendanceCodeUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<AttendanceCodeModel> call(int clubId) {
    return _repository.getTodayCode(clubId);
  }
}
