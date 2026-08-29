import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/di_providers.dart';
import '../widgets/check_in_button.dart';
import '../widgets/member_attendance_list_item.dart';
import '../widgets/study_summary_card.dart';

/// 스터디 홈 화면의 "출석현황" 탭 — 이번 작업 범위의 핵심 화면.
///
/// - 오늘의 출석 여부: 멤버별 행 오른쪽의 배지(MemberAttendanceListItem의
///   _TodayBadge)로 표시.
/// - 이번주의 출석 현황 정보: 상단 요약 카드의 "이번주 출석률" + 멤버별 행의
///   월~일 요일 도장(_DayDot)으로 표시.
/// - 휴가 일수: 상단 요약 카드의 "내 휴가 일수".
/// - 출석하기: 리스트 위에 떠 있는(floating) CheckInButton. home_page.dart의
///   TeamRegisterButton처럼 Stack + Positioned로 콘텐츠 위에 띄우되, 버튼
///   자체 스타일은 club_detail_page.dart의 "지원 하기" 버튼(AppRoundedButton)
///   과 동일하다(요청사항).
///
/// 데이터는 studyAttendanceOverviewProvider(clubId)를 통해 지금은 전부
/// Mock(MockAttendanceDataSource)에서 온다 — 백엔드에 아직 출석/인원 API
/// 계약이 없다(features/attendance/data_source/attendance_data_source.dart
/// 주석 참고). 계약이 생기면 데이터소스만 교체하면 되고 이 화면은 그대로
/// 재사용된다.
class StudyAttendanceTab extends ConsumerWidget {
  const StudyAttendanceTab({super.key, required this.clubId});

  final int clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(studyAttendanceOverviewProvider(clubId));

    return overviewAsync.when(
      data: (overview) => Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(studyAttendanceOverviewProvider(clubId));
              await ref.read(studyAttendanceOverviewProvider(clubId).future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              // 아래에 떠 있는 CheckInButton(대략 60(버튼 높이) + 24*2(여백) =
              // 108)에 마지막 멤버 행이 가리지 않도록 넉넉히 여백을 둔다.
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                StudySummaryCard(overview: overview),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Text(
                    '멤버 출석',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                  ),
                ),
                for (final member in overview.members) MemberAttendanceListItem(member: member),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: CheckInButton(clubId: clubId, overview: overview),
          ),
        ],
      ),
      // RefreshIndicator가 당김 동작을 인식하려면 스크롤 가능한 자손이 있어야
      // 해서, 로딩/에러 상태도 home_page.dart의 _HomeFeedTab과 같은 패턴으로
      // AlwaysScrollableScrollPhysics를 준 ListView로 감쌌다. 데이터를 아직
      // 못 받아온 상태라 출석하기 버튼은 보여주지 않는다.
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
              '출석 현황을 불러오지 못했어요: $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8B8B8B), fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
