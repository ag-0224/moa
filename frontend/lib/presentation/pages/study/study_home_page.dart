import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/club/models/club_model.dart';
import '../../providers/auth/auth_controller.dart';
import '../../providers/auth/auth_state.dart';
import 'study_management_page.dart';
import 'tabs/study_attendance_tab.dart';
import 'tabs/study_board_placeholder_tab.dart';
import 'tabs/study_my_info_placeholder_tab.dart';

/// 가입한 스터디(동아리)를 눌렀을 때 들어오는 전용 화면.
///
/// AppBar(스터디 이름 + 관리자 전용 설정 버튼) + 3개 탭(출석현황/게시판/내 정보)
/// 셸 역할만 하고, home_page.dart에서 ClubHomePlaceholderPage를 대체한다.
///
/// 이번 작업 범위는 "출석현황" 탭까지라, 게시판/내 정보 탭과 관리자 설정
/// 화면(StudyManagementPage)은 아직 준비 중인 자리표시자다(각 파일 주석 참고).
class StudyHomePage extends ConsumerWidget {
  const StudyHomePage({super.key, required this.club});

  final ClubModel club;

  static const int _tabCount = 3;

  /// 로그인한 사용자가 이 스터디의 대표(회장)인지 임시로 판별한다.
  ///
  /// 백엔드에 클럽별 "내 역할"(leaderId/role 등) 필드가 아직 없어서
  /// (docs/API_CONTRACT.md, openapi.yaml Club/ClubDetail 스키마 참고) 지금은
  /// 이름 문자열이 club.leaderName과 같은지로 대신 판별한다. 동명이인이 있으면
  /// 잘못 판별될 수 있는 임시방편이므로, 정확히 판별하려면 계약 변경(예: Club에
  /// isLeader 또는 memberRole 필드 추가, $moa-change-api-contract)이 필요하다.
  bool _isLeader(WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    if (authState is! AuthAuthenticated) return false;
    final myName = authState.user.nickname ?? authState.user.name;
    return myName == club.leaderName;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLeader = _isLeader(ref);

    return DefaultTabController(
      length: _tabCount,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          // 다른 화면들(club_apply_page.dart, edit_profile_page.dart 등)과 같은
          // 뒤로가기 버튼으로 통일한다 — AppBar 기본 leading(플랫폼별 아이콘이
          // 달라짐) 대신 항상 검정 Icons.arrow_back을 명시적으로 쓴다.
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            club.name,
            style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            if (isLeader)
              IconButton(
                tooltip: '스터디 관리',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => StudyManagementPage(club: club)),
                  );
                },
                icon: const Icon(Icons.settings_outlined, color: Colors.black),
              ),
          ],
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Color(0xFF8B8B8B),
            indicatorColor: Color(0xFF31C1FF),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            tabs: [
              Tab(text: '출석현황'),
              Tab(text: '게시판'),
              Tab(text: '내 정보'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StudyAttendanceTab(clubId: club.id),
            const StudyBoardPlaceholderTab(),
            const StudyMyInfoPlaceholderTab(),
          ],
        ),
      ),
    );
  }
}
