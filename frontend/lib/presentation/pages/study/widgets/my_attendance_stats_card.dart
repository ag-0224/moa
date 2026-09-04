import 'package:flutter/material.dart';

import '../../../../features/attendance/models/my_study_info_model.dart';

const _statsCardBackground = Color(0xFFF5F8FF);
const _statsGrayText = Color(0xFF8B8B8B);
const _statsDividerColor = Color(0xFFE0E6F5);

/// "내 정보" 탭의 "휴가 및 출석 정보" 카드 — 이번 달 출석/결석 일수와 이번
/// 학기 휴가 사용 현황을 보여준다. study_summary_card.dart와 같은 카드
/// 스타일(연한 파란 배경, 둥근 모서리 16)을 재사용해서 디자인을 통일했다.
class MyAttendanceStatsCard extends StatelessWidget {
  const MyAttendanceStatsCard({super.key, required this.info});

  final MyStudyInfoModel info;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(color: _statsCardBackground, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
            child: _StatBlock(
              label: '이번 달 출석',
              value: '${info.presentCount}일',
              valueColor: const Color(0xFF31C1FF),
            ),
          ),
          Container(width: 1, height: 40, color: _statsDividerColor),
          Expanded(
            child: _StatBlock(
              label: '이번 달 결석',
              value: '${info.absentCount}일',
              valueColor: const Color(0xFFFF6B6B),
            ),
          ),
          Container(width: 1, height: 40, color: _statsDividerColor),
          Expanded(
            child: _StatBlock(
              label: '휴가 사용',
              value: '${info.vacationDaysUsed}/${info.vacationDaysTotal}일',
              valueColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value, required this.valueColor});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _statsGrayText, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: valueColor)),
      ],
    );
  }
}
