import '../data_source/attendance_data_source.dart';
import '../models/study_attendance_overview_model.dart';
import 'attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  AttendanceRepositoryImpl(this._dataSource);

  final AttendanceDataSource _dataSource;

  @override
  Future<StudyAttendanceOverviewModel> getOverview(int clubId) {
    return _dataSource.getOverview(clubId);
  }

  @override
  Future<void> checkIn(int clubId) {
    return _dataSource.checkIn(clubId);
  }
}
