import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/di_providers.dart';
import '../widgets/monthly_attendance_calendar.dart';
import '../widgets/my_attendance_stats_card.dart';

const _tabGrayText = Color(0xFF8B8B8B);
const _tabDangerRed = Color(0xFFE57373);

/// 스터디 홈 화면의 "내 정보" 탭.
///
/// - 월별 출석 현황: MonthlyAttendanceCalendar. 헤더 화살표(<, >)로 이전/다음
///   달로 넘기거나, 달 글자를 눌러 showDatePicker로 원하는 달/연도를 바로
///   고를 수 있다 — 지금 보고 있는 달(_selectedMonth)은 이 위젯의 로컬
///   상태로 관리한다.
/// - 휴가 및 출석 정보: MyAttendanceStatsCard(선택한 달의 출석/결석 + 휴가 사용).
/// - 스터디 탈퇴: 백엔드에 탈퇴(멤버십 삭제) API가 아직 없어서(가입/승인만
///   있고 탈퇴는 docs/API_CONTRACT.md에 없음) study_management_page.dart의
///   다른 메뉴들과 같은 방식으로 "준비중" 표시만 하는 정보성 자리다.
///
/// 데이터는 myStudyInfoProvider((clubId, month))를 통해
/// studyAttendanceOverviewProvider와 마찬가지로 실제 서버
/// (AttendanceApiDataSourceImpl)에서 온다. 출석하기 버튼(check_in_button.dart)이
/// 오늘 출석/휴가를 확정하면 "이번 달" 항목만 invalidate해서, 이번 달을 보고
/// 있을 때는 두 탭이 항상 같은 "오늘" 상태를 보여준다.
class StudyMyInfoTab extends ConsumerStatefulWidget {
  const StudyMyInfoTab({super.key, required this.clubId});

  final int clubId;

  @override
  ConsumerState<StudyMyInfoTab> createState() => _StudyMyInfoTabState();
}

class _StudyMyInfoTabState extends ConsumerState<StudyMyInfoTab> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
  }

  static int _monthIndex(DateTime d) => d.year * 12 + d.month;

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  /// 화살표로 스터디가 생성되기 이전 달까지는 갈 수 없다 — [earliestMonth]는
  /// 서버가 내려준 studyCreatedAt이 속한 달의 1일이다(스터디마다 고정값).
  bool _canGoToPreviousMonth(DateTime earliestMonth) =>
      _monthIndex(_selectedMonth) > _monthIndex(earliestMonth);

  void _goToPreviousMonth(DateTime earliestMonth) {
    if (!_canGoToPreviousMonth(earliestMonth)) return;
    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1));
  }

  void _goToNextMonth() {
    if (_isCurrentMonth) return; // 미래 달은 아직 기록이 없다.
    setState(() => _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1));
  }

  Future<void> _openMonthPicker(DateTime earliestMonth) async {
    final now = DateTime.now();
    final lastDayOfCurrentMonth = DateTime(now.year, now.month + 1, 0);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: earliestMonth,
      lastDate: lastDayOfCurrentMonth,
      initialDatePickerMode: DatePickerMode.year,
      helpText: '월 선택',
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedMonth = DateTime(picked.year, picked.month, 1));
  }

  @override
  Widget build(BuildContext context) {
    final params = (clubId: widget.clubId, month: _selectedMonth);
    final infoAsync = ref.watch(myStudyInfoProvider(params));

    return infoAsync.when(
      data: (info) {
        final earliestMonth = DateTime(info.studyCreatedAt.year, info.studyCreatedAt.month, 1);
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myStudyInfoProvider(params));
            await ref.read(myStudyInfoProvider(params).future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const _SectionTitle('월별 출석 현황'),
              MonthlyAttendanceCalendar(
                info: info,
                canGoToPreviousMonth: _canGoToPreviousMonth(earliestMonth),
                canGoToNextMonth: !_isCurrentMonth,
                onPreviousMonth: () => _goToPreviousMonth(earliestMonth),
                onNextMonth: _goToNextMonth,
                onTapMonthLabel: () => _openMonthPicker(earliestMonth),
              ),
              const _SectionTitle('휴가 및 출석 정보'),
              MyAttendanceStatsCard(info: info),
              const _SectionTitle('스터디 탈퇴'),
              const _LeaveStudyTile(),
            ],
          ),
        );
      },
      // RefreshIndicator가 당김 동작을 인식하려면 스크롤 가능한 자손이 있어야
      // 해서, 로딩/에러 상태도 다른 탭들과 같은 패턴으로 AlwaysScrollableScrollPhysics를
      // 준 ListView로 감쌌다.
      loading: () => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.only(top: 200),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
      error: (error, _) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
            child: Text(
              '내 정보를 불러오지 못했어요: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _tabGrayText, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
      ),
    );
  }
}

/// 스터디 탈퇴 안내 타일. 실제로 탈퇴시키는 기능은 아직 연결하지 않았다 —
/// study_management_page.dart의 "준비중" 메뉴들과 같은 태도.
class _LeaveStudyTile extends StatelessWidget {
  const _LeaveStudyTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEFEF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.logout, color: _tabDangerRed, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '스터디 탈퇴',
              style: TextStyle(fontSize: 15, color: _tabDangerRed, fontWeight: FontWeight.w600),
            ),
          ),
          const Text('준비중', style: TextStyle(fontSize: 12, color: _tabGrayText)),
        ],
      ),
    );
  }
}
