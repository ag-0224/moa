import '../models/study_attendance_overview_model.dart';
import '../repositories/attendance_repository.dart';

class GetStudyAttendanceOverviewUseCase {
  GetStudyAttendanceOverviewUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<StudyAttendanceOverviewModel> call(int clubId) {
    return _repository.getOverview(clubId);
  }
}
