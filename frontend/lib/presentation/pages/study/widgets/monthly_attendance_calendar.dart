import 'package:flutter/material.dart';

import '../../../../features/attendance/models/attendance_mark.dart';
import '../../../../features/attendance/models/my_study_info_model.dart';

const _weekdayHeaderLabels = ['월', '화', '수', '목', '금', '토', '일'];
const _calendarGrayText = Color(0xFF8B8B8B);
const _emptyCellColor = Color(0xFFF0F0F0);
const _todayRingColor = Color(0xFF1F8FCC);

/// "내 정보" 탭의 "월별 출석 현황" 달력.
///
/// 날짜 칸을 출석(파랑)/결석(빨강)/휴가(주황)로 색칠하고, 아직 지나지 않은
/// 날(오늘 중 아직 출석번호를 입력하거나 휴가를 쓰지 않은 경우 포함)은 옅은
/// 회색 빈 칸으로 둔다. 오늘 칸은 테두리로 표시한다.
///
/// 상단 헤더의 화살표(<, >)로 이전/다음 달로 넘기거나, "n년 n월" 글자를
/// 눌러 달력(showDatePicker)으로 원하는 달/연도를 바로 고를 수 있다. 실제
/// 어느 달을 보여줄지는 상위(StudyMyInfoTab)가 관리하고, 이 위젯은 화면
/// 표시와 콜백 호출만 담당한다.
class MonthlyAttendanceCalendar extends StatelessWidget {
  const MonthlyAttendanceCalendar({
    super.key,
    required this.info,
    required this.canGoToPreviousMonth,
    required this.canGoToNextMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onTapMonthLabel,
  });

  final MyStudyInfoModel info;

  /// 스터디 생성일이 속한 달까지 왔으면(그 이전은 출석을 기록할 수 없었던
  /// 날들이라) 이전 달 화살표를 비활성화한다.
  final bool canGoToPreviousMonth;

  /// 미래 달은 아직 아무 기록도 없어서, 이번 달을 보고 있으면 다음 달 화살표를
  /// 비활성화한다.
  final bool canGoToNextMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onTapMonthLabel;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = info.daysInMonth;
    final leadingOffset = DateTime(info.month.year, info.month.month, 1).weekday - 1;
    final today = DateTime.now();
    final isCurrentMonth = today.year == info.month.year && today.month == info.month.month;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: canGoToPreviousMonth ? onPreviousMonth : null,
                icon: Icon(
                  Icons.chevron_left,
                  color: canGoToPreviousMonth ? Colors.black : _calendarGrayText.withValues(alpha: 0.4),
                ),
                visualDensity: VisualDensity.compact,
              ),
              InkWell(
                onTap: onTapMonthLabel,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${info.month.year}년 ${info.month.month}월',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.calendar_month_outlined, size: 16, color: _calendarGrayText),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: canGoToNextMonth ? onNextMonth : null,
                icon: Icon(
                  Icons.chevron_right,
                  color: canGoToNextMonth ? Colors.black : _calendarGrayText.withValues(alpha: 0.4),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final label in _weekdayHeaderLabels)
                Expanded(
                  child: Center(
                    child: Text(label, style: const TextStyle(fontSize: 12, color: _calendarGrayText)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: leadingOffset + daysInMonth,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index < leadingOffset) return const SizedBox.shrink();
              final day = index - leadingOffset + 1;
              final mark = info.dailyMarks[day];
              final isToday = isCurrentMonth && day == today.day;
              return _DayCell(day: day, mark: mark, isToday: isToday);
            },
          ),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _LegendDot(color: Color(0xFF31C1FF), label: '출석'),
              _LegendDot(color: Color(0xFFFF6B6B), label: '결석'),
              _LegendDot(color: Color(0xFFFFB84D), label: '휴가'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.mark, required this.isToday});

  final int day;
  final AttendanceMark? mark;
  final bool isToday;

  Color get _background {
    switch (mark) {
      case AttendanceMark.present:
        return const Color(0xFF31C1FF);
      case AttendanceMark.absent:
        return const Color(0xFFFF6B6B);
      case AttendanceMark.vacation:
        return const Color(0xFFFFB84D);
      case AttendanceMark.upcoming:
      case null:
        return _emptyCellColor;
    }
  }

  Color get _textColor {
    switch (mark) {
      case AttendanceMark.present:
      case AttendanceMark.absent:
      case AttendanceMark.vacation:
        return Colors.white;
      case AttendanceMark.upcoming:
      case null:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _background,
          shape: BoxShape.circle,
          border: isToday ? Border.all(color: _todayRingColor, width: 2) : null,
        ),
        child: Text('$day', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textColor)),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: _calendarGrayText)),
      ],
    );
  }
}
