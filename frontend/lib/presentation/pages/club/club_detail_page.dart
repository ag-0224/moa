import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/assets.dart';
import '../../../features/club/models/club_application_status.dart';
import '../../../features/club/models/club_detail_model.dart';
import '../../providers/di_providers.dart';
import '../../widgets/common/button/app_rounded_button.dart';
import 'club_apply_page.dart';

/// 가입하지 않은 동아리를 눌렀을 때 보여주는 소개 화면(사진 + 이름 + 대표자 +
/// 소개 글 + "지원 하기" 버튼). 사용자가 제공한 스크린샷 기준으로 만들었다.
///
/// 이미 가입한 동아리는 이 화면을 거치지 않고 바로 다른 화면(현재는
/// ClubHomePlaceholderPage)으로 이동한다 — home_page.dart의 탭 처리 참고.
class ClubDetailPage extends ConsumerWidget {
  const ClubDetailPage({super.key, required this.clubId});

  final int clubId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(clubDetailProvider(clubId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: detailAsync.when(
          data: (club) => _ClubDetailView(club: club, clubId: clubId),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('동아리 정보를 불러오지 못했어요: $error', textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClubDetailView extends StatelessWidget {
  const _ClubDetailView({required this.club, required this.clubId});

  final ClubDetailModel club;
  final int clubId;

  static const Color _grayText = Color(0xFF8B8B8B);
  static const double _heroHeight = 280;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _heroHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              club.thumbnailUrl != null
                  ? Image.network(club.thumbnailUrl!, fit: BoxFit.cover)
                  : Image.asset(Assets.clubDefaultThumbnail, fit: BoxFit.cover),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleIconButton(
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      _CircleIconButton(
                        icon: Icons.share,
                        onTap: () {
                          // TODO: 공유 기능. 이번 작업 범위는 소개/지원 화면까지다.
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // TODO: majesticons 왕관 아이콘 에셋이 추가되면 이 Material
                            // 아이콘을 그걸로 교체한다(다른 하단 탭 아이콘들과 같은 패턴).
                            const Icon(Icons.emoji_events, size: 18, color: _grayText),
                            const SizedBox(width: 6),
                            Text(club.leaderName, style: const TextStyle(fontSize: 15, color: _grayText)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFE5E5EA), height: 1),
                        const SizedBox(height: 20),
                        Text(
                          club.description?.isNotEmpty == true ? club.description! : '아직 등록된 소개 글이 없어요.',
                          style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _ApplyButton(club: club, clubId: clubId),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

/// applicationStatus에 따라 다른 모습을 보여주는 하단 버튼.
/// - joined인데 이 화면에 온 경우(승인 직후 등 드문 경쟁 상태) 대비용 안내.
/// - none/rejected: "지원 하기"/"다시 지원하기" — 누르면 ClubApplyPage로 이동.
/// - pending: 비활성화된 "승인 대기 중".
class _ApplyButton extends ConsumerWidget {
  const _ApplyButton({required this.club, required this.clubId});

  final ClubDetailModel club;
  final int clubId;

  static const Color _blue = Color(0xFF31C1FF);
  static const Color _disabledBackground = Color(0xFFE5E5EA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (club.isJoined) {
      return const AppRoundedButton(
        onPressed: null,
        backgroundColor: _disabledBackground,
        foregroundColor: Colors.black54,
        child: Text('이미 가입된 동아리예요', style: TextStyle(fontWeight: FontWeight.w600)),
      );
    }

    switch (club.applicationStatus) {
      case ClubApplicationStatus.pending:
        return const AppRoundedButton(
          onPressed: null,
          backgroundColor: _disabledBackground,
          foregroundColor: Colors.black54,
          child: Text('승인 대기 중', style: TextStyle(fontWeight: FontWeight.w600)),
        );
      case ClubApplicationStatus.rejected:
        return AppRoundedButton(
          onPressed: () => _openApplyPage(context, ref),
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          child: const Text('다시 지원하기', style: TextStyle(fontWeight: FontWeight.w600)),
        );
      case ClubApplicationStatus.none:
        return AppRoundedButton(
          onPressed: () => _openApplyPage(context, ref),
          backgroundColor: _blue,
          foregroundColor: Colors.white,
          child: const Text('지원 하기', style: TextStyle(fontWeight: FontWeight.w600)),
        );
    }
  }

  Future<void> _openApplyPage(BuildContext context, WidgetRef ref) async {
    final applied = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ClubApplyPage(clubId: clubId, clubName: club.name)),
    );
    if (applied == true) {
      ref.invalidate(clubDetailProvider(clubId));
    }
  }
}
