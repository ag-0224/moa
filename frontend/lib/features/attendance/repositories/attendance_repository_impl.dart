import '../data_source/attendance_data_source.dart';
import '../models/my_study_info_model.dart';
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
  Future<void> checkIn(int clubId, String code) {
    return _dataSource.checkIn(clubId, code);
  }

  @override
  Future<void> useVacation(int clubId) {
    return _dataSource.useVacation(clubId);
  }

  @override
  Future<MyStudyInfoModel> getMyMonthlyInfo(int clubId, DateTime month) {
    return _dataSource.getMyMonthlyInfo(clubId, month);
  }
}
