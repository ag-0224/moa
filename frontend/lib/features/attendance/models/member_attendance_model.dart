import 'attendance_mark.dart';

/// 스터디 인원 한 명의 출석 현황 한 행.
///
/// 실제 인원 목록/출석 기록 API가 아직 없어서(도메인 필드는 openapi.yaml에
/// 없음) MockAttendanceDataSource가 만들어내는 값이다. 클릭 시 전공/학번/
/// 자기소개를 보여주는 멤버 상세 화면과 관리자 전용 액션(휴가 부여/추방)은
/// 이번 작업 범위에 포함되지 않는다 — 사용자가 요청한 "우선 출석 현황 탭부터"
/// 범위를 지키기 위해 별도 이슈로 남겨둔다.
class MemberAttendanceModel {
  const MemberAttendanceModel({
    required this.memberId,
    required this.name,
    required this.isMe,
    required this.todayMark,
    required this.weeklyMarks,
    required this.vacationDaysUsed,
  });

  final int memberId;
  final String name;

  /// 로그인한 사용자 본인의 행인지. "출석하기" 버튼이 어느 행의 오늘 상태를
  /// 바꿔야 하는지 알아야 해서 필요하다 — 아직 실제 인원 API가 없어
  /// MockAttendanceDataSource가 임의로 한 명을 "나"로 지정해서 채운다.
  final bool isMe;

  /// 오늘의 출석 여부.
  final AttendanceMark todayMark;

  /// 이번 주 월~일 7일치 출석 도장. 아직 지나지 않은 요일은
  /// AttendanceMark.upcoming.
  final List<AttendanceMark> weeklyMarks;

  /// 이번 학기(또는 이번 주) 누적 휴가 사용 일수.
  final int vacationDaysUsed;
}
