import 'dart:math';

import '../models/attendance_exceptions.dart';
import '../models/attendance_mark.dart';
import '../models/member_attendance_model.dart';
import '../models/study_attendance_overview_model.dart';
import 'attendance_data_source.dart';

/// AttendanceDataSource의 임시 구현체.
///
/// 백엔드에 스터디 인원/출석/휴가 API가 아직 없어서, 실제 네트워크 호출 대신
/// clubId로 시드를 고정한 난수로 그럴듯한 목(mock) 데이터를 만들어낸다(같은
/// clubId면 재조회해도 항상 같은 데이터가 나와서 화면 확인이 편하다). 실제
/// API가 생기면 이 클래스 전체를 지우고 AttendanceApiDataSourceImpl로
/// 교체한다 — 위쪽 계층(Repository/UseCase/Provider)은 바뀌지 않는다.
///
/// 멤버 목록 중 항상 0번째(isMe: true, 이름 "나")를 로그인한 사용자 본인
/// 자리로 취급한다. 실제 인원 API가 없어서 "나"를 진짜로 식별할 방법이 없기
/// 때문에 임시로 고정한 것이고, checkIn()/useVacation()이 건드리는 것도 이
/// 자리뿐이다.
class MockAttendanceDataSource implements AttendanceDataSource {
  static const _names = ['김민지', '이도현', '최유진', '정하은', '오지훈', '한소율'];

  /// 실제로는 스터디 대표가 "출석번호 확인" 화면(StudyManagementPage, 아직
  /// 미구현)에서 매번 새로 발급하는 번호여야 하지만, 그 화면이 생기기 전까지는
  /// 테스트용으로 고정된 4자리 번호를 정답으로 둔다.
  static const String testAttendanceCode = '1234';

  /// clubId별 "오늘 내가 출석번호를 맞혀서 출석 처리됐는지" 상태.
  final Map<int, bool> _checkedInToday = {};

  /// clubId별 "오늘 내가 휴가를 쓰기로 했는지" 상태. checkIn과 배타적이라(둘
  /// 다 될 수 없음) 한쪽을 선택하면 반대쪽 기록은 지운다.
  final Map<int, bool> _vacationToday = {};

  @override
  Future<StudyAttendanceOverviewModel> getOverview(int clubId) async {
    // 실제 네트워크 호출처럼 로딩 상태를 잠깐 보여주기 위한 인위적인 지연.
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final random = Random(clubId);
    final now = DateTime.now();
    // 월요일을 이번 주 시작으로 잡는다 (DateTime.weekday: 월=1 ... 일=7).
    final weekStart = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final todayIndex = now.weekday - 1; // 0=월 ... 6=일
    final iCheckedInToday = _checkedInToday[clubId] ?? false;
    final iUsedVacationToday = _vacationToday[clubId] ?? false;

    final otherMemberCount = 3 + random.nextInt(4); // 나를 포함해 4~7명
    final members = List.generate(otherMemberCount + 1, (i) {
      final isMe = i == 0;

      final weeklyMarks = List.generate(7, (dayIndex) {
        if (dayIndex > todayIndex) return AttendanceMark.upcoming;
        if (isMe && dayIndex == todayIndex) {
          // "나"의 오늘 칸만 출석하기 버튼(출석번호 입력 또는 휴가 사용)으로
          // 실제로 바뀐다. 아직 아무것도 선택하지 않았으면 "예정"으로 둔다.
          if (iCheckedInToday) return AttendanceMark.present;
          if (iUsedVacationToday) return AttendanceMark.vacation;
          return AttendanceMark.upcoming;
        }
        // 결석/휴가는 드물게, 대부분은 출석으로 가중치를 둔다.
        final roll = random.nextInt(10);
        if (roll < 7) return AttendanceMark.present;
        if (roll < 9) return AttendanceMark.absent;
        return AttendanceMark.vacation;
      });

      return MemberAttendanceModel(
        memberId: i,
        name: isMe ? '나' : _names[(i - 1) % _names.length],
        isMe: isMe,
        todayMark: weeklyMarks[todayIndex],
        weeklyMarks: weeklyMarks,
        vacationDaysUsed: weeklyMarks.where((m) => m == AttendanceMark.vacation).length,
      );
    });

    return StudyAttendanceOverviewModel(
      weekStart: weekStart,
      members: members,
      myVacationDaysUsed: members.first.vacationDaysUsed,
      myVacationDaysTotal: 3,
    );
  }

  @override
  Future<void> checkIn(int clubId, String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (code != testAttendanceCode) {
      throw const InvalidAttendanceCodeException();
    }
    _checkedInToday[clubId] = true;
    _vacationToday.remove(clubId);
  }

  @override
  Future<void> useVacation(int clubId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _vacationToday[clubId] = true;
    _checkedInToday.remove(clubId);
  }
}
