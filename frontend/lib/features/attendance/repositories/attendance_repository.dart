import '../models/study_attendance_overview_model.dart';

abstract class AttendanceRepository {
  Future<StudyAttendanceOverviewModel> getOverview(int clubId);

  Future<void> checkIn(int clubId);
}
