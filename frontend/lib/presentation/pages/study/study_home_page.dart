import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/club/models/club_model.dart';
import 'study_management_page.dart';
import 'tabs/study_attendance_tab.dart';
import 'tabs/study_board_placeholder_tab.dart';
import 'tabs/study_my_info_tab.dart';

/// 가입한 스터디(동아리)를 눌렀을 때 들어오는 전용 화면.
///
/// AppBar(스터디 이름 + 관리자 전용 설정 버튼) + 3개 탭(출석현황/게시판/내 정보)
/// 셸 역할만 하고, home_page.dart에서 ClubHomePlaceholderPage를 대체한다.
///
/// 이번 작업 범위는 "출석현황" 탭까지라, 게시판/내 정보 탭은 아직 준비 중인
/// 자리표시자다(각 파일 주석 참고). 관리자 설정 화면(StudyManagementPage)은
/// clubs.leader_id 인프라가 생기면서 실제로 연결됐다.
class StudyHomePage extends ConsumerWidget {
  const StudyHomePage({super.key, required this.club});

  final ClubModel club;

  static const int _tabCount = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // club.isLeader는 서버가 clubs.leader_id와 로그인한 사용자 ID를 비교해서
    // 채워주는 값이다(GET /clubs, GET /clubs/me, GET /clubs/{clubId} 공통) —
    // 예전에는 이 필드가 없어서 닉네임/이름 문자열을 club.leaderName과
    // 비교하는 임시방편을 썼는데, 동명이인이 있으면 잘못 판별될 수 있는
    // 보안 구멍이었다. 다만 이 club 값 자체는 화면에 들어올 때 전달받은
    // 스냅샷이라, 이 화면 안에서 관리자 권한을 넘기면(TransferLeadershipPage)
    // 목록 화면으로 돌아갈 때까지는 갱신되지 않는다 — 그래서 권한 넘기기는
    // 성공 시 스터디 목록까지 pop해서 나간다.
    final isLeader = club.isLeader;

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
            StudyMyInfoTab(clubId: club.id),
          ],
        ),
      ),
    );
  }
}
