import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/club/models/club_model.dart';
import '../../providers/di_providers.dart';
import 'club_applications_page.dart';
import 'study_attendance_code_page.dart';
import 'study_edit_page.dart';
import 'transfer_leadership_page.dart';

const _grayText = Color(0xFF8B8B8B);

/// 스터디 관리 화면. AppBar의 설정 버튼(관리자 전용, study_home_page.dart)이
/// 들어오는 곳이다.
///
/// 다섯 메뉴 모두 clubs.leader_id 인프라(관리자 판별)와 이번에 추가된
/// PATCH/DELETE /clubs/{clubId}, GET /clubs/{clubId}/attendance/code
/// 계약으로 전부 실제 화면과 연결됐다.
class StudyManagementPage extends ConsumerStatefulWidget {
  const StudyManagementPage({super.key, required this.club});

  final ClubModel club;

  @override
  ConsumerState<StudyManagementPage> createState() => _StudyManagementPageState();
}

class _StudyManagementPageState extends ConsumerState<StudyManagementPage> {
  bool _isDeleting = false;

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('스터디 삭제'),
        content: Text(
          '"${widget.club.name}"을(를) 삭제하면 멤버, 가입 신청, 출석 기록이 모두 함께\n'
          '삭제되고 복구할 수 없어요.\n정말 삭제하시겠어요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // await 이후에 ScaffoldMessenger.of(context)/Navigator.of(context)를 호출하면,
    // 그 사이에 사용자가 뒤로가기 등으로 화면을 벗어나 위젯이 deactivate된 경우
    // "Looking up a deactivated widget's ancestor is unsafe" 에러가 난다.
    // mounted 체크만으로는 막을 수 없으므로(디액티베이트된 상태에서도 mounted는
    // true다), await 전에 미리 참조를 캡처해두고 그 참조만 사용한다
    // (club_apply_page.dart의 _submit()과 같은 패턴).
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isDeleting = true);
    try {
      await ref.read(deleteClubUseCaseProvider)(widget.club.id);
      if (!mounted) return;

      // 삭제된 스터디가 목록에서 사라지도록 새로고침한다.
      ref.invalidate(myClubsProvider);
      ref.invalidate(allClubsProvider);

      messenger.showSnackBar(const SnackBar(content: Text('스터디를 삭제했어요.')));
      // 삭제된 스터디의 하위 화면(스터디 홈/관리)에는 더 이상 머물 수 없으므로
      // 목록 화면까지 한 번에 나간다(TransferLeadershipPage와 같은 패턴).
      navigator.popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      messenger.showSnackBar(
        SnackBar(content: Text('스터디를 삭제하지 못했어요: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;

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
        child: AbsorbPointer(
          absorbing: _isDeleting,
          child: Opacity(
            opacity: _isDeleting ? 0.5 : 1,
            child: ListView(
              children: [
                _ManagementMenuTile(
                  icon: Icons.edit_outlined,
                  label: '스터디 정보 수정',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => StudyEditPage(clubId: club.id)),
                    );
                  },
                ),
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
                _ManagementMenuTile(
                  icon: Icons.badge_outlined,
                  label: '출석번호 확인',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => StudyAttendanceCodePage(clubId: club.id)),
                    );
                  },
                ),
                const Divider(height: 1, color: Color(0xFFEFEFEF)),
                _ManagementMenuTile(
                  icon: Icons.delete_outline,
                  label: '스터디 삭제',
                  isDanger: true,
                  onTap: _confirmAndDelete,
                ),
              ],
            ),
          ),
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
    final color = isReady ? (isDanger ? Colors.red : Colors.black) : (isDanger ? const Color(0xFFE57373) : _grayText);

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
