import 'package:flutter/material.dart';

import '../../../../features/attendance/models/member_attendance_model.dart';
import '../../../widgets/common/attendance/attendance_day_dot.dart';
import '../../../widgets/common/attendance/attendance_status_badge.dart';

const _itemGrayText = Color(0xFF8B8B8B);
const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

/// 멤버 한 명의 출석 현황 한 줄: 아바타 + 이름 + 이번주 요일별 도장
/// (AttendanceDayDot) + 오늘 출석 배지(AttendanceStatusBadge).
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
                      AttendanceDayDot(label: _weekdayLabels[i], mark: member.weeklyMarks[i]),
                      if (i != member.weeklyMarks.length - 1) const SizedBox(width: 6),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AttendanceStatusBadge(mark: member.todayMark),
        ],
      ),
    );
  }
}
