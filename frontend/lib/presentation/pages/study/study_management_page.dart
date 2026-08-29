import 'package:flutter/material.dart';

import '../../../features/club/models/club_model.dart';

const _grayText = Color(0xFF8B8B8B);

/// 스터디 관리 화면(정보 수정 / 출석번호 확인 / 스터디 삭제)의 자리표시자.
///
/// 이번 작업 범위는 "출석현황 탭"까지라 실제 관리 기능은 아직 구현하지
/// 않았다. AppBar의 설정 버튼(관리자 전용)이 들어갈 화면이 있어야 해서
/// 우선 메뉴 3개를 비활성 상태로 보여준다. 실제 구현 시 각 메뉴는 별도
/// 이슈로 나누는 게 좋다: 정보 수정(계약 변경 없음, PATCH 필요할 수 있음),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                '${club.name} 관리 기능은 아직 준비중이에요.',
                style: const TextStyle(fontSize: 13, color: _grayText),
              ),
            ),
            const _ManagementMenuTile(icon: Icons.edit_outlined, label: '스터디 정보 수정'),
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
  const _ManagementMenuTile({required this.icon, required this.label, this.isDanger = false});

  final IconData icon;
  final String label;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    // 아직 기능이 연결되지 않아 항상 비활성(회색/연한 빨강) 상태로만 보여준다.
    final color = isDanger ? const Color(0xFFE57373) : _grayText;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 16),
          Text(label, style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Text('준비중', style: TextStyle(fontSize: 12, color: _grayText)),
        ],
      ),
    );
  }
}
