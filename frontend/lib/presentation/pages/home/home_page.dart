import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/club/models/club_model.dart';
import '../../../features/health/models/health_status.dart';
import '../../providers/auth/auth_controller.dart';
import '../../providers/auth/auth_state.dart';
import '../../providers/di_providers.dart';
import '../../providers/home/main_tab_provider.dart';
import '../../widgets/common/navigation/app_bottom_nav_bar.dart';
import '../club/club_detail_page.dart';
import '../club/club_home_placeholder_page.dart';
import 'widgets/club_list_item.dart';
import 'widgets/club_section_header.dart';
import 'widgets/club_search_bar.dart';
import 'widgets/favorite_action_sheet.dart';
import 'widgets/home_app_bar.dart';
import 'widgets/team_register_button.dart';

/// docs/USER_FLOW.md의 '메인 홈 Screen' (Figma node-id 3073-49).
///
/// 하단 탭(홈/통계/마이페이지)을 가진 셸(shell) 역할만 하고, 실제 화면은
/// IndexedStack의 각 탭 위젯이 그린다. TechTalk의 MainPage(presentation/pages/
/// main/main_page.dart)가 PageView + BottomNavigationBar로 탭을 구성하는 것과
/// 같은 구조를 참고했지만, MOA는 코드 생성(@riverpod)을 쓰지 않으므로
/// MainTab enum + 평범한 StateProvider(main_tab_provider.dart)로 단순화했다.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(mainTabProvider);
    final isSearching = ref.watch(isClubSearchingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: currentTab.index,
        children: const [
          _HomeFeedTab(),
          _StatsPlaceholderTab(),
          _MyPageTab(),
        ],
      ),
      // 동아리 검색 중에는 하단 탭 바를 숨긴다(Figma 검색 화면 참고).
      bottomNavigationBar: isSearching
          ? null
          : AppBottomNavBar(
              currentIndex: currentTab.index,
              onTap: (index) => ref.read(mainTabProvider.notifier).state = MainTab.values[index],
              items: [
                for (final tab in MainTab.values)
                  AppBottomNavBarItem(iconAsset: tab.iconAsset, selectedIconAsset: tab.selectedIconAsset, label: tab.label),
              ],
            ),
    );
  }
}

/// 홈 탭: 상단 헤더 + (즐겨찾기/전체 동아리 목록) + 스크롤에 반응해 모양이
/// 바뀌는 "팀 등록하기" 플로팅 버튼.
///
/// 광고 배너는 Figma 목업에 자리가 있었지만 이번 작업 범위에서는 의도적으로
/// 구현하지 않았다(요청사항: "광고배너는 아직 구현하지 않도록 해").
class _HomeFeedTab extends ConsumerStatefulWidget {
  const _HomeFeedTab();

  @override
  ConsumerState<_HomeFeedTab> createState() => _HomeFeedTabState();
}

class _HomeFeedTabState extends ConsumerState<_HomeFeedTab> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    // 검색 중에 이 화면을 벗어나는 경우(탭 전환은 검색 중엔 막혀 있지만
    // 로그아웃 등으로도 dispose될 수 있다)를 대비해 공유 상태를 초기화한다.
    ref.read(isClubSearchingProvider.notifier).state = false;
    super.dispose();
  }

  void _startSearch() => ref.read(isClubSearchingProvider.notifier).state = true;

  void _stopSearch() {
    ref.read(isClubSearchingProvider.notifier).state = false;
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
  }

  /// 동아리를 탭했을 때: 이미 가입한 동아리면 곧바로 해당 동아리 화면으로
  /// 이동하고(아직 전용 홈 화면이 없어 임시 화면), 가입하지 않은 동아리면
  /// 소개/지원 화면(ClubDetailPage)을 보여준다.
  void _handleClubTap(ClubModel club) {
    if (club.isJoined) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ClubHomePlaceholderPage(club: club)),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ClubDetailPage(clubId: club.id)),
      );
    }
  }

  Future<void> _handleClubLongPress(ClubModel club, Offset anchor) async {
    final confirmed = await showFavoriteActionSheet(
      context: context,
      anchor: anchor,
      isFavorite: club.isFavorite,
    );
    if (confirmed != true) return;
    if (!mounted) return;

    await ref.read(setClubFavoriteUseCaseProvider)(club.id, !club.isFavorite);
    ref.invalidate(myClubsProvider);
    ref.invalidate(allClubsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = ref.watch(isClubSearchingProvider);

    return Stack(
      children: [
        Column(
          children: [
            if (isSearching)
              ClubSearchBar(
                controller: _searchController,
                onBack: _stopSearch,
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            else
              HomeAppBar(onSearchTap: _startSearch),
            Expanded(
              child: isSearching
                  ? ref.watch(allClubsProvider).when(
                      data: (clubs) => _ClubSearchResultsView(
                        clubs: clubs,
                        query: _searchQuery,
                        onTapClub: _handleClubTap,
                        onLongPressClub: _handleClubLongPress,
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('검색에 실패했어요: $error')),
                    )
                  : ref.watch(myClubsProvider).when(
                      data: (clubs) => _ClubListView(
                        clubs: clubs,
                        scrollController: _scrollController,
                        onTapClub: _handleClubTap,
                        onLongPressClub: _handleClubLongPress,
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('동아리 목록을 불러오지 못했어요: $error')),
                    ),
            ),
          ],
        ),
        if (!isSearching)
          Positioned(
            right: 20,
            bottom: 24,
            child: TeamRegisterButton(
              scrollController: _scrollController,
              onPressed: () {
                // TODO: 팀(동아리) 등록 화면 연결. 이번 작업 범위는 메인 페이지 UI까지다.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('팀 등록 화면은 아직 준비중이에요.')),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// 검색 모드에서 보여주는 결과 목록. 검색어가 비어 있으면 아무것도 보여주지
/// 않고(Figma 목업 상태), 검색어가 있으면 "가입된 동아리"와 "가입하지 않은
/// 동아리"를 나눠서 보여준다 — 메인 피드(_ClubListView)와 같은
/// ClubSectionHeader + ClubListItem 조합을 그대로 재사용해서 디자인을
/// 통일했다. 동아리 "이름"만 기준으로 부분 일치(대소문자 무시)한다.
class _ClubSearchResultsView extends StatelessWidget {
  const _ClubSearchResultsView({
    required this.clubs,
    required this.query,
    required this.onTapClub,
    required this.onLongPressClub,
  });

  final List<ClubModel> clubs;
  final String query;
  final void Function(ClubModel club) onTapClub;
  final void Function(ClubModel club, Offset anchor) onLongPressClub;

  @override
  Widget build(BuildContext context) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    final results = clubs
        .where((club) => club.name.toLowerCase().contains(trimmedQuery.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('검색 결과가 없어요.', style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 15)),
      );
    }

    final joined = results.where((club) => club.isJoined).toList();
    final notJoined = results.where((club) => !club.isJoined).toList();

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      children: [
        if (joined.isNotEmpty) ...[
          const ClubSectionHeader(title: '가입된 동아리'),
          for (final club in joined)
            ClubListItem(
              club: club,
              onTap: () => onTapClub(club),
              onLongPress: (anchor) => onLongPressClub(club, anchor),
            ),
        ],
        if (notJoined.isNotEmpty) ...[
          const ClubSectionHeader(title: '가입하지 않은 동아리'),
          for (final club in notJoined) ClubListItem(club: club, onTap: () => onTapClub(club)),
        ],
      ],
    );
  }
}

class _ClubListView extends StatelessWidget {
  const _ClubListView({
    required this.clubs,
    required this.scrollController,
    required this.onTapClub,
    required this.onLongPressClub,
  });

  final List<ClubModel> clubs;
  final ScrollController scrollController;
  final void Function(ClubModel club) onTapClub;
  final void Function(ClubModel club, Offset anchor) onLongPressClub;

  @override
  Widget build(BuildContext context) {
    if (clubs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '아직 소속된 동아리가 없어요.\n관심있는 동아리를 찾아 가입해보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 15),
          ),
        ),
      );
    }

    final favorites = clubs.where((club) => club.isFavorite).toList();

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        if (favorites.isNotEmpty) ...[
          const ClubSectionHeader(title: '즐겨찾기'),
          for (final club in favorites)
            ClubListItem(
              club: club,
              onTap: () => onTapClub(club),
              onLongPress: (anchor) => onLongPressClub(club, anchor),
            ),
        ],
        const ClubSectionHeader(title: '전체'),
        for (final club in clubs)
          ClubListItem(
            club: club,
            onTap: () => onTapClub(club),
            onLongPress: (anchor) => onLongPressClub(club, anchor),
          ),
      ],
    );
  }
}

/// 통계 탭은 이번 작업 범위(메인 페이지 Figma 목업)에 화면이 없어 자리만
/// 잡아두는 placeholder다.
class _StatsPlaceholderTab extends StatelessWidget {
  const _StatsPlaceholderTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('통계 화면은 아직 준비중이에요.', style: TextStyle(color: Color(0xFF8B8B8B))),
    );
  }
}

/// 마이페이지 탭. 리팩토링 전 home_page.dart의 내용(사용자 정보 + 서버 상태 +
/// 로그아웃)을 그대로 옮겨왔다.
class _MyPageTab extends ConsumerWidget {
  const _MyPageTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('마이페이지'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text('안녕하세요, ${user.name}님', style: Theme.of(context).textTheme.titleLarge),
              Text(user.email),
              const SizedBox(height: 24),
            ],
            Text('서버 상태', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _HealthStatusView(),
          ],
        ),
      ),
    );
  }
}

class _HealthStatusView extends ConsumerWidget {
  const _HealthStatusView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkHealth = ref.watch(checkHealthUseCaseProvider);

    return FutureBuilder<HealthStatus>(
      future: checkHealth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('확인 중...');
        }
        if (snapshot.hasError) {
          return Text(
            '서버에 연결할 수 없습니다: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }
        final health = snapshot.data!;
        return Text('${health.status} · ${health.timestamp}');
      },
    );
  }
}
