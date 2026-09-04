import 'attendance_mark.dart';

/// 스터디 홈 화면 "내 정보" 탭 하나를 그리는 데 필요한 데이터 — 이번 달
/// 출석 달력 + 휴가/출석 통계.
class MyStudyInfoModel {
  const MyStudyInfoModel({
    required this.month,
    required this.dailyMarks,
    required this.presentCount,
    required this.absentCount,
    required this.vacationDaysUsed,
    required this.vacationDaysTotal,
    required this.studyCreatedAt,
  });

  /// 이번 달 1일(자정).
  final DateTime month;

  /// 1일부터 시작하는 날짜(day-of-month) -> 출석 표시. 아직 지나지 않은
  /// 날(오늘 중 아직 출석/휴가를 정하지 않은 경우 포함)은 이 맵에 없다 —
  /// MonthlyAttendanceCalendar가 이걸 "비어있는 칸"으로 그린다.
  final Map<int, AttendanceMark> dailyMarks;

  /// 이번 달 출석/결석 일수, 이번 학기 휴가 사용/총 일수.
  final int presentCount;
  final int absentCount;
  final int vacationDaysUsed;
  final int vacationDaysTotal;

  /// 스터디가 만들어진 날짜. 스터디마다 고정된 값이라, 월별 달력 화면에서
  /// 이 날짜가 속한 달보다 더 이전 달로는 넘어갈 수 없게 막는 하한선으로
  /// 쓴다(그 이전은 애초에 출석을 기록할 수 없었던 날이라 결석으로 잡히지
  /// 않는다 — docs/API_CONTRACT.md "스터디 생성일 이전 날짜는 출석 대상이
  /// 아님" 참고).
  final DateTime studyCreatedAt;

  int get daysInMonth => DateTime(month.year, month.month + 1, 0).day;

  /// year/month는 서버가 조회한 달을 그대로 돌려주는 값이라 그 둘로 [month]를
  /// 만든다(openapi.yaml의 MyStudyInfo 스키마 참고). dailyMarks의 JSON 키는
  /// 항상 문자열("1", "2", ...)이라 int로 파싱해서 쓴다.
  factory MyStudyInfoModel.fromJson(Map<String, dynamic> json) {
    final year = json['year'] as int;
    final monthValue = json['month'] as int;
    final rawDailyMarks = json['dailyMarks'] as Map<String, dynamic>;

    return MyStudyInfoModel(
      month: DateTime(year, monthValue, 1),
      dailyMarks: rawDailyMarks.map(
        (key, value) => MapEntry(int.parse(key), AttendanceMark.fromJson(value as String)),
      ),
      presentCount: json['presentCount'] as int,
      absentCount: json['absentCount'] as int,
      vacationDaysUsed: json['vacationDaysUsed'] as int,
      vacationDaysTotal: json['vacationDaysTotal'] as int,
      studyCreatedAt: DateTime.parse(json['studyCreatedAt'] as String),
    );
  }
}
