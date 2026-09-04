import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/club/models/club_application_model.dart';
import '../../providers/di_providers.dart';

const _grayText = Color(0xFF8B8B8B);
const _dangerRed = Color(0xFFE57373);
const _blue = Color(0xFF31C1FF);

/// "스터디 관리" 화면의 "가입 신청 관리" 메뉴가 여는 화면. 현재 동아리장이
/// 대기 중인(PENDING) 가입 신청서를 승인/거절한다
/// (GET/POST /clubs/{clubId}/applications...).
///
/// 승인하면 club_members에 실제로 가입되고 memberCount가 늘어나므로, 목록/
/// 상세 화면에 보이는 인원수도 최신 상태로 갱신되도록 함께 무효화한다.
class ClubApplicationsPage extends ConsumerStatefulWidget {
  const ClubApplicationsPage({super.key, required this.clubId});

  final int clubId;

  @override
  ConsumerState<ClubApplicationsPage> createState() => _ClubApplicationsPageState();
}

class _ClubApplicationsPageState extends ConsumerState<ClubApplicationsPage> {
  final Set<int> _processingApplicationIds = {};

  Future<void> _refreshAfterDecision() async {
    ref.invalidate(pendingClubApplicationsProvider(widget.clubId));
    await ref.read(pendingClubApplicationsProvider(widget.clubId).future);
  }

  Future<void> _approve(ClubApplicationModel application) async {
    // await 이후에 ScaffoldMessenger.of(context)를 호출하면, 그 사이에 사용자가
    // 뒤로가기 등으로 화면을 벗어나 위젯이 deactivate된 경우 "Looking up a
    // deactivated widget's ancestor is unsafe" 에러가 난다. mounted 체크만으로는
    // 막을 수 없으므로(디액티베이트된 상태에서도 mounted는 true다), await 전에
    // 미리 참조를 캡처해두고 그 참조만 사용한다(club_apply_page.dart의
    // _submit()과 같은 패턴).
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _processingApplicationIds.add(application.id));
    try {
      await ref.read(approveClubApplicationUseCaseProvider)(widget.clubId, application.id);
      // memberCount가 늘어났으므로 스터디 목록/상세에 보이는 인원수도 갱신한다.
      ref.invalidate(myClubsProvider);
      ref.invalidate(allClubsProvider);
      ref.invalidate(clubDetailProvider(widget.clubId));
      await _refreshAfterDecision();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('${application.applicantName}님의 가입을 승인했어요.')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('승인하지 못했어요: $e')));
      }
    } finally {
      if (mounted) setState(() => _processingApplicationIds.remove(application.id));
    }
  }

  Future<void> _reject(ClubApplicationModel application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('가입 신청 거절'),
        content: Text('${application.applicantName}님의 신청을 거절할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('거절')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // 위 _approve()와 같은 이유로, await 전에 미리 캡처해두고 그 참조만 쓴다.
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _processingApplicationIds.add(application.id));
    try {
      await ref.read(rejectClubApplicationUseCaseProvider)(widget.clubId, application.id);
      await _refreshAfterDecision();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('${application.applicantName}님의 신청을 거절했어요.')),
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('거절하지 못했어요: $e')));
      }
    } finally {
      if (mounted) setState(() => _processingApplicationIds.remove(application.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(pendingClubApplicationsProvider(widget.clubId));

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
          '가입 신청 관리',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: applicationsAsync.when(
          data: (applications) {
            if (applications.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshAfterDecision,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(top: 160),
                      child: Center(
                        child: Text('대기 중인 가입 신청이 없어요.', style: TextStyle(color: _grayText, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refreshAfterDecision,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: applications.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEFEFEF)),
                itemBuilder: (context, index) {
                  final application = applications[index];
                  final isProcessing = _processingApplicationIds.contains(application.id);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.applicantName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          application.selfIntroduction,
                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isProcessing ? null : () => _reject(application),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _dangerRed,
                                  side: const BorderSide(color: _dangerRed),
                                ),
                                child: const Text('거절'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isProcessing ? null : () => _approve(application),
                                style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white),
                                child: isProcessing
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Text('승인'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '신청 목록을 불러오지 못했어요: $error',
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
