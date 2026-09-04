import 'attendance_mark.dart';
import 'member_attendance_model.dart';

/// 스터디 출석 현황 탭 하나를 그리는 데 필요한 데이터 전부.
///
/// openapi.yaml의 AttendanceOverview 스키마와 매핑된다. weekStart는 이번 주
/// 월요일(자정)이고, 요일별 라벨(월~일)을 만드는 데 쓴다.
class StudyAttendanceOverviewModel {
  const StudyAttendanceOverviewModel({
    required this.weekStart,
    required this.members,
    required this.myVacationDaysUsed,
    required this.myVacationDaysTotal,
  });

  final DateTime weekStart;
  final List<MemberAttendanceModel> members;

  /// 로그인한 사용자 본인의 이번 학기 휴가 사용/총 일수.
  final int myVacationDaysUsed;
  final int myVacationDaysTotal;

  factory StudyAttendanceOverviewModel.fromJson(Map<String, dynamic> json) {
    return StudyAttendanceOverviewModel(
      weekStart: DateTime.parse(json['weekStart'] as String),
      members: (json['members'] as List<dynamic>)
          .map((member) => MemberAttendanceModel.fromJson(member as Map<String, dynamic>))
          .toList(),
      myVacationDaysUsed: json['myVacationDaysUsed'] as int,
      myVacationDaysTotal: json['myVacationDaysTotal'] as int,
    );
  }

  /// 오늘 출석한 인원 수 (present만 카운트, vacation/upcoming 제외).
  int get presentTodayCount =>
      members.where((m) => m.todayMark == AttendanceMark.present).length;

  int get totalMemberCount => members.length;

  /// 로그인한 사용자 본인 행. isMe로 표시된 멤버가 항상 하나 있다는 전제다
  /// (서버가 가입한 스터디에 대해서만 이 응답을 내려주므로, 로그인한
  /// 사용자 본인이 members 안에 항상 포함된다).
  MemberAttendanceModel get me => members.firstWhere((m) => m.isMe, orElse: () => members.first);

  /// "출석하기" 버튼이 자신의 상태를 판단하는 데 쓰는 나의 오늘 출석 여부.
  AttendanceMark get myTodayMark => me.todayMark;

  /// 이번 주(오늘까지) 전체 인원의 출석률. 아직 지나지 않은 요일과 휴가는
  /// 분모/분자에서 제외한다(출석/결석만 집계).
  double get weeklyAttendanceRate {
    var counted = 0;
    var present = 0;
    for (final member in members) {
      for (final mark in member.weeklyMarks) {
        if (mark == AttendanceMark.present || mark == AttendanceMark.absent) {
          counted++;
          if (mark == AttendanceMark.present) present++;
        }
      }
    }
    if (counted == 0) return 0;
    return present / counted;
  }
}
