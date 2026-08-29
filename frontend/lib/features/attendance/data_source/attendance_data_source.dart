import '../models/study_attendance_overview_model.dart';

/// 스터디 출석 현황 데이터 소스 인터페이스.
///
/// 지금은 MockAttendanceDataSource 구현체 하나뿐이다. 백엔드에 실제 출석
/// API(예: GET /clubs/{clubId}/attendance)가 생기면 $moa-change-api-contract
/// 절차를 따라 AttendanceApiDataSourceImpl을 새로 추가하고
/// di_providers.dart에서 이 구현체로 바꿔 끼우면 된다(club feature의
/// ClubDataSource/ClubApiDataSourceImpl과 동일한 패턴).
abstract class AttendanceDataSource {
  Future<StudyAttendanceOverviewModel> getOverview(int clubId);

  /// 로그인한 사용자 본인의 오늘 출석을 "출석"으로 표시한다(출석하기 버튼).
  Future<void> checkIn(int clubId);
}
