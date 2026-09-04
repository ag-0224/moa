import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/club/models/club_member_model.dart';
import '../../providers/di_providers.dart';

const _grayText = Color(0xFF8B8B8B);

/// "스터디 관리" 화면의 "관리자 권한 넘기기" 메뉴가 여는 화면. 현재 동아리장이
/// 다른 가입 멤버 한 명을 골라 관리자 권한을 넘긴다(PATCH /clubs/{clubId}/leader).
///
/// 권한을 넘기고 나면 이 화면을 연 사용자는 더 이상 이 스터디의 관리자가
/// 아니다. StudyHomePage의 "관리자 설정" 버튼은 화면에 들어올 때 전달받은
/// ClubModel 스냅샷(club.isLeader)을 그대로 쓰기 때문에, 이 화면 하나만
/// pop해서는 그 값이 갱신되지 않는다 — 그래서 성공하면 myClubsProvider/
/// allClubsProvider를 무효화한 뒤 스터디 목록 화면까지 한 번에 pop한다
/// (StudyHomePage/StudyManagementPage를 모두 지나서 나간다).
class TransferLeadershipPage extends ConsumerStatefulWidget {
  const TransferLeadershipPage({super.key, required this.clubId, required this.clubName});

  final int clubId;
  final String clubName;

  @override
  ConsumerState<TransferLeadershipPage> createState() => _TransferLeadershipPageState();
}

class _TransferLeadershipPageState extends ConsumerState<TransferLeadershipPage> {
  bool _isTransferring = false;

  Future<void> _confirmAndTransfer(ClubMemberModel member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('관리자 권한 넘기기'),
        content: Text(
          '${member.name}님에게 "${widget.clubName}"의 관리자 권한을 넘길까요?\n'
          '넘기고 나면 새 관리자가 다시 넘겨주기 전까지는 되돌릴 수 없어요.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('넘기기')),
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

    setState(() => _isTransferring = true);
    try {
      await ref.read(transferClubLeadershipUseCaseProvider)(widget.clubId, member.userId);
      if (!mounted) return;

      // 스터디 목록에 보이는 leaderName/isLeader를 최신 상태로 갱신한다.
      ref.invalidate(myClubsProvider);
      ref.invalidate(allClubsProvider);

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('완료'),
          content: Text('${member.name}님에게 관리자 권한을 넘겼어요.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('확인')),
          ],
        ),
      );

      if (!mounted) return;
      // 더 이상 관리자가 아니므로 이 화면과 스터디 관리/스터디 홈 화면을
      // 모두 지나 스터디 목록으로 돌아간다.
      navigator.popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        setState(() => _isTransferring = false);
        messenger.showSnackBar(
          SnackBar(content: Text('권한을 넘기지 못했어요: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(clubMembersProvider(widget.clubId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          '관리자 권한 넘기기',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: membersAsync.when(
          data: (members) {
            final candidates = members.where((member) => !member.isLeader).toList();

            if (candidates.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '권한을 넘길 다른 멤버가 없어요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _grayText, fontSize: 15),
                  ),
                ),
              );
            }

            return AbsorbPointer(
              absorbing: _isTransferring,
              child: Opacity(
                opacity: _isTransferring ? 0.5 : 1,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: candidates.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEFEFEF)),
                  itemBuilder: (context, index) {
                    final member = candidates[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFFF0F0F0),
                        child: Text(
                          member.name.substring(0, 1),
                          style: const TextStyle(color: _grayText, fontWeight: FontWeight.w600),
                        ),
                      ),
                      title: Text(member.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      trailing: const Icon(Icons.chevron_right, color: _grayText),
                      onTap: () => _confirmAndTransfer(member),
                    );
                  },
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '멤버 목록을 불러오지 못했어요: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _grayText, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
