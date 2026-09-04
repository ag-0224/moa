import 'package:flutter/material.dart';

import '../../../features/club/models/club_model.dart';
import 'club_applications_page.dart';
import 'transfer_leadership_page.dart';

const _grayText = Color(0xFF8B8B8B);

/// 스터디 관리 화면. AppBar의 설정 버튼(관리자 전용, study_home_page.dart)이
/// 들어오는 곳이다.
///
/// "가입 신청 관리"와 "관리자 권한 넘기기"는 clubs.leader_id 인프라가 생기면서
/// 실제 화면으로 연결했다. 나머지 세 메뉴(정보 수정/출석번호 확인/스터디
/// 삭제)는 이번 변경 범위 밖이라 여전히 "준비중" 자리표시자다 — 각각 별도
/// 이슈로 남겨둔다: 정보 수정(계약 변경 없음, PATCH 필요할 수 있음),
/// 출석번호 확인(신규 API), 스터디 삭제(신규 API + 확인 다이얼로그).
class StudyManagementPage extends StatelessWidget {
  const StudyManagementPage({super.key, required this.club});

  final ClubModel club;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // 다른 화면들과 같은 뒤로가기 버튼으로 통일한다(study_home_page.dart 참고).
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          '스터디 관리',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const _ManagementMenuTile(icon: Icons.edit_outlined, label: '스터디 정보 수정'),
            const Divider(height: 1, color: Color(0xFFEFEFEF)),
            _ManagementMenuTile(
              icon: Icons.how_to_reg_outlined,
              label: '가입 신청 관리',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ClubApplicationsPage(clubId: club.id)),
                );
              },
            ),
            const Divider(height: 1, color: Color(0xFFEFEFEF)),
            _ManagementMenuTile(
              icon: Icons.admin_panel_settings_outlined,
              label: '관리자 권한 넘기기',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TransferLeadershipPage(clubId: club.id, clubName: club.name),
                  ),
                );
              },
            ),
            const Divider(height: 1, color: Color(0xFFEFEFEF)),
            const _ManagementMenuTile(icon: Icons.badge_outlined, label: '출석번호 확인'),
            const Divider(height: 1, color: Color(0xFFEFEFEF)),
            const _ManagementMenuTile(icon: Icons.delete_outline, label: '스터디 삭제', isDanger: true),
          ],
        ),
      ),
    );
  }
}

class _ManagementMenuTile extends StatelessWidget {
  const _ManagementMenuTile({required this.icon, required this.label, this.isDanger = false, this.onTap});

  final IconData icon;
  final String label;
  final bool isDanger;

  /// null이면 아직 연결되지 않은 메뉴라 "준비중" 배지를 보여주고 탭해도
  /// 아무 동작을 하지 않는다.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isReady = onTap != null;
    final color = isReady ? Colors.black : (isDanger ? const Color(0xFFE57373) : _grayText);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w500)),
            const Spacer(),
            if (isReady)
              const Icon(Icons.chevron_right, color: _grayText)
            else
              const Text('준비중', style: TextStyle(fontSize: 12, color: _grayText)),
          ],
        ),
      ),
    );
  }
}
