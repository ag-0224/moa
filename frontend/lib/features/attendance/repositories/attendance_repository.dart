import '../models/my_study_info_model.dart';
import '../models/study_attendance_overview_model.dart';

abstract class AttendanceRepository {
  Future<StudyAttendanceOverviewModel> getOverview(int clubId);

  Future<void> checkIn(int clubId, String code);

  Future<void> useVacation(int clubId);

  Future<MyStudyInfoModel> getMyMonthlyInfo(int clubId, DateTime month);
}
