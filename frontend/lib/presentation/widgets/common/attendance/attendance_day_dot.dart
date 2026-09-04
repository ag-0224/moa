import 'package:flutter/material.dart';

import '../../../../features/attendance/models/attendance_mark.dart';

const _dotGrayText = Color(0xFF8B8B8B);

/// 하루치 출석 상태를 나타내는 작은 원 도장 + 요일 라벨 한 쌍.
///
/// 원래 study/tabs/study_attendance_tab.dart가 그리는 멤버별 출석 행
/// (MemberAttendanceListItem) 안에 private `_DayDot`으로만 있던 위젯이다.
/// 홈 화면 통계 탭의 스터디별 카드(StudyAttendanceSummaryCard)도 같은
/// 스타일의 요일 도장이 필요해서 공용 위젯으로 뺐다 — 색상 기준
/// (AttendanceMark -> Color)이 두 군데서 갈라지지 않도록 여기 한 곳에서만
/// 정의한다.
class AttendanceDayDot extends StatelessWidget {
  const AttendanceDayDot({super.key, required this.label, required this.mark});

  final String label;
  final AttendanceMark mark;

  Color get _color {
    switch (mark) {
      case AttendanceMark.present:
        return const Color(0xFF31C1FF);
      case AttendanceMark.absent:
        return const Color(0xFFFF6B6B);
      case AttendanceMark.vacation:
        return const Color(0xFFFFB84D);
      case AttendanceMark.upcoming:
        return const Color(0xFFE5E5EA);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 16, height: 16, decoration: BoxDecoration(color: _color, shape: BoxShape.circle)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: _dotGrayText)),
      ],
    );
  }
}
