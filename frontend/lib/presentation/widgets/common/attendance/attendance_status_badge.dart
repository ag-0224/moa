import 'package:flutter/material.dart';

import '../../../../features/attendance/models/attendance_mark.dart';

const _badgeGrayText = Color(0xFF8B8B8B);

/// 하루치 출석 상태(AttendanceMark)를 "출석/결석/휴가/예정" 알약(pill)
/// 배지로 보여준다.
///
/// 원래 study/tabs/study_attendance_tab.dart가 그리는 멤버별 출석 행
/// (MemberAttendanceListItem) 안에 오늘 상태만 보여주는 private
/// `_TodayBadge`로만 있던 위젯이다. 홈 화면 통계 탭의 스터디별 카드
/// (StudyAttendanceSummaryCard)도 오늘 상태 배지가 필요해서 공용 위젯으로
/// 뺐다 — 색/문구 기준(AttendanceMark -> (문구, 배경색, 글자색))이 두 군데서
/// 갈라지지 않도록 여기 한 곳에서만 정의한다.
class AttendanceStatusBadge extends StatelessWidget {
  const AttendanceStatusBadge({super.key, required this.mark});

  final AttendanceMark mark;

  (String, Color, Color) get _spec {
    switch (mark) {
      case AttendanceMark.present:
        return ('출석', const Color(0xFF31C1FF), Colors.white);
      case AttendanceMark.absent:
        return ('결석', const Color(0xFFFF6B6B), Colors.white);
      case AttendanceMark.vacation:
        return ('휴가', const Color(0xFFFFB84D), Colors.white);
      case AttendanceMark.upcoming:
        return ('예정', const Color(0xFFE5E5EA), _badgeGrayText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (text, background, foreground) = _spec;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: foreground)),
    );
  }
}
