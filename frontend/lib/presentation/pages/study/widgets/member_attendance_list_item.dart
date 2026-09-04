import 'package:flutter/material.dart';

import '../../../../features/attendance/models/attendance_mark.dart';
import '../../../../features/attendance/models/member_attendance_model.dart';

const _itemGrayText = Color(0xFF8B8B8B);
const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

/// 멤버 한 명의 출석 현황 한 줄: 아바타 + 이름 + 이번주 요일별 도장(_DayDot)
/// + 오늘 출석 배지(_TodayBadge).
///
/// 탭하면 전공/학번/자기소개를 보여주는 멤버 상세 화면(관리자는 휴가 부여/
/// 추방 버튼도 함께)으로 들어가는 동작은 이번 작업 범위(출석현황 탭)에
/// 포함되지 않아 아직 연결하지 않았다. 다음 단계에서 이어서 구현한다.
class MemberAttendanceListItem extends StatelessWidget {
  const MemberAttendanceListItem({super.key, required this.member});

  final MemberAttendanceModel member;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFF0F0F0),
            child: Text(
              member.name.substring(0, 1),
              style: const TextStyle(color: _itemGrayText, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (var i = 0; i < member.weeklyMarks.length; i++) ...[
                      _DayDot(label: _weekdayLabels[i], mark: member.weeklyMarks[i]),
                      if (i != member.weeklyMarks.length - 1) const SizedBox(width: 6),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _TodayBadge(mark: member.todayMark),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({required this.label, required this.mark});

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
        Text(label, style: const TextStyle(fontSize: 9, color: _itemGrayText)),
      ],
    );
  }
}

class _TodayBadge extends StatelessWidget {
  const _TodayBadge({required this.mark});

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
        return ('예정', const Color(0xFFE5E5EA), _itemGrayText);
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
