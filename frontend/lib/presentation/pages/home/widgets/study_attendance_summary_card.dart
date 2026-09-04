import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/assets.dart';
import '../../../../features/club/models/club_model.dart';
import '../../../providers/di_providers.dart';
import '../../../widgets/common/attendance/attendance_day_dot.dart';
import '../../../widgets/common/attendance/attendance_status_badge.dart';

const _cardGrayText = Color(0xFF8B8B8B);
const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

/// 통계 탭의 스터디 한 개당 행 — 이 스터디에서 로그인한 사용자 본인의
/// 이번 주(월~일) 출석 도장과 오늘 상태를 보여준다.
///
/// study/tabs/study_attendance_tab.dart의 MemberAttendanceListItem은 스터디
/// "하나"의 멤버 전체 행을 보여주는 반면, 이 위젯은 "가입한 모든 스터디"
/// 각각에 대해 로그인한 사용자 본인 행(overview.me)만 뽑아서 보여준다는
/// 점이 다르다. 배경색 있는 카드가 아니라 MemberAttendanceListItem과 같은
/// 배경 없는 리스트 행 스타일로 통일했다(요청사항 — "스터디 출석 현황처럼
/// 리스트별 배경 색깔이 없도록"). 데이터는 study_attendance_tab.dart와
/// 동일하게 studyAttendanceOverviewProvider(clubId)를 그대로 재사용한다 —
/// 이미 그 스터디 홈 화면(출석현황 탭)을 열어본 적이 있다면 캐시된 Future를
/// 그대로 쓰게 된다. 멤버 전체 목록이나 휴가 일수 같은 상세 정보는 이
/// 행의 범위가 아니다(탭해서 StudyHomePage로 들어가면 볼 수 있다).
class StudyAttendanceSummaryCard extends ConsumerWidget {
  const StudyAttendanceSummaryCard({super.key, required this.club, this.onTap});

  final ClubModel club;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(studyAttendanceOverviewProvider(club.id));

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 44,
                height: 44,
                child: club.thumbnailUrl != null
                    ? Image.network(club.thumbnailUrl!, fit: BoxFit.cover)
                    : Image.asset(Assets.clubDefaultThumbnail, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  overviewAsync.when(
                    data: (overview) => Row(
                      children: [
                        for (var i = 0; i < overview.me.weeklyMarks.length; i++) ...[
                          AttendanceDayDot(label: _weekdayLabels[i], mark: overview.me.weeklyMarks[i]),
                          if (i != overview.me.weeklyMarks.length - 1) const SizedBox(width: 6),
                        ],
                      ],
                    ),
                    loading: () => const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    error: (error, _) => const Text(
                      '출석 정보를 불러오지 못했어요',
                      style: TextStyle(fontSize: 12, color: _cardGrayText),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            overviewAsync.maybeWhen(
              data: (overview) => AttendanceStatusBadge(mark: overview.myTodayMark),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
