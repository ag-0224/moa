import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/user/models/user_model.dart';
import '../../providers/auth/auth_controller.dart';
import '../../providers/auth/auth_state.dart';
import 'edit_profile_page.dart';

/// 마이페이지('내 정보') 탭. 하단 탭의 루트 화면이라 뒤로가기(leading)는 두지
/// 않고, AppBar 스타일만 club_apply_page.dart와 통일했다(요청사항).
///
/// 리팩토링 전 home_page.dart에 있던 서버 상태(_HealthStatusView) 표시는
/// 이 화면의 목적(개인정보 수정/로그아웃/회원탈퇴)과 무관해서 들어내고,
/// 대신 프로필 요약 + 메뉴 3개(개인정보 수정/로그아웃/회원 탈퇴)로 바꿨다.
class MyPageTab extends ConsumerWidget {
  const MyPageTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '내 정보',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 32),
          children: [
            if (user != null) _ProfileSummary(user: user),
            const SizedBox(height: 32),
            _MyPageMenuTile(
              icon: Icons.edit_outlined,
              label: '개인정보 수정',
              onTap: user == null
                  ? null
                  : () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
                      );
                    },
            ),
            const Divider(height: 1, color: Color(0xFFEFEFEF)),
            _MyPageMenuTile(
              icon: Icons.logout,
              label: '로그아웃',
              onTap: () => _confirmSignOut(context, ref),
            ),
            const Divider(height: 1, color: Color(0xFFEFEFEF)),
            _MyPageMenuTile(
              icon: Icons.person_remove_outlined,
              label: '회원 탈퇴',
              color: Colors.red,
              onTap: () => _confirmDeleteAccount(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('로그아웃 하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).signOut();
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('탈퇴하면 계정 정보와 가입한 동아리 정보가 모두 삭제되고 복구할 수 없어요.\n정말 탈퇴하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await ref.read(authControllerProvider.notifier).deleteAccount();
    if (!context.mounted) return;

    result.when(
      success: (_) {},
      failure: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원 탈퇴에 실패했어요: $error')),
        );
      },
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final displayName = user.nickname ?? user.name;

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(color: Color(0xFFF0F0F0), shape: BoxShape.circle),
          child: const Icon(Icons.person, color: Color(0xFF8B8B8B), size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(fontSize: 14, color: Color(0xFF8B8B8B)),
              ),
              if (user.major != null || user.studentId != null) ...[
                const SizedBox(height: 2),
                Text(
                  [
                    if (user.major != null) user.major!,
                    if (user.studentId != null) user.studentId!,
                  ].join(' · '),
                  style: const TextStyle(fontSize: 14, color: Color(0xFF8B8B8B)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MyPageMenuTile extends StatelessWidget {
  const _MyPageMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor = onTap == null ? const Color(0xFFBDBDBD) : (color ?? Colors.black);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: resolvedColor, size: 22),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 16, color: resolvedColor, fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFFBDBDBD)),
          ],
        ),
      ),
    );
  }
}
