import 'package:flutter/material.dart';

import '../../../../features/attendance/models/study_attendance_overview_model.dart';

const _cardBackground = Color(0xFFF5F8FF);
const _summaryGrayText = Color(0xFF8B8B8B);
const _summaryBlue = Color(0xFF31C1FF);

/// 출석현황 탭 상단의 "이번주 출석률 / 내 휴가 일수" 요약 카드.
///
/// - 이번주 출석률: overview.weeklyAttendanceRate (오늘까지 지난 요일만 집계).
/// - 내 휴가 일수: overview.myVacationDaysUsed/myVacationDaysTotal.
class StudySummaryCard extends StatelessWidget {
  const StudySummaryCard({super.key, required this.overview});

  final StudyAttendanceOverviewModel overview;

  @override
  Widget build(BuildContext context) {
    final ratePercent = (overview.weeklyAttendanceRate * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(color: _cardBackground, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: _StatBlock(
              label: '이번주 출석률',
              value: '$ratePercent%',
              caption: '오늘 ${overview.presentTodayCount}/${overview.totalMemberCount}명 출석',
              valueColor: _summaryBlue,
            ),
          ),
          Container(width: 1, height: 44, color: const Color(0xFFE0E6F5)),
          Expanded(
            child: _StatBlock(
              label: '내 휴가 일수',
              value: '${overview.myVacationDaysUsed}/${overview.myVacationDaysTotal}일',
              caption: '이번 학기 사용',
              valueColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value, required this.caption, required this.valueColor});

  final String label;
  final String value;
  final String caption;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: _summaryGrayText, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: valueColor)),
        const SizedBox(height: 4),
        Text(caption, style: const TextStyle(fontSize: 12, color: _summaryGrayText)),
      ],
    );
  }
}
