import '../models/my_study_info_model.dart';
import '../repositories/attendance_repository.dart';

/// 스터디 홈 화면 "내 정보" 탭이 호출하는 유스케이스.
class GetMyStudyInfoUseCase {
  GetMyStudyInfoUseCase(this._repository);

  final AttendanceRepository _repository;

  Future<MyStudyInfoModel> call(int clubId, DateTime month) {
    return _repository.getMyMonthlyInfo(clubId, month);
  }
}
