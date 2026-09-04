import '../models/my_study_info_model.dart';
import '../models/study_attendance_overview_model.dart';

/// 스터디 출석 현황 데이터 소스 인터페이스.
///
/// 실제 구현체는 AttendanceApiDataSourceImpl이다(openapi.yaml의
/// /clubs/{clubId}/attendance/* 계약, club feature의
/// ClubDataSource/ClubApiDataSourceImpl과 동일한 패턴).
abstract class AttendanceDataSource {
  Future<StudyAttendanceOverviewModel> getOverview(int clubId);

  /// 로그인한 사용자 본인의 오늘 출석을 "출석"으로 표시한다. code가 오늘의
  /// 출석번호와 다르면 InvalidAttendanceCodeException을 던진다.
  Future<void> checkIn(int clubId, String code);

  /// 로그인한 사용자 본인이 오늘 휴가를 쓰기로 함(결석 처리하지 않음).
  Future<void> useVacation(int clubId);

  /// "내 정보" 탭이 보여주는 출석 달력 + 휴가/출석 통계. month는 조회하려는
  /// 달의 아무 날짜나 상관없다(년/월만 본다) — 화살표나 달력으로 다른
  /// 달/연도를 선택했을 때 그 달을 넘긴다.
  Future<MyStudyInfoModel> getMyMonthlyInfo(int clubId, DateTime month);
}
