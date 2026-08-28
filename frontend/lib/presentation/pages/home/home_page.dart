import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/club/models/club_model.dart';
import '../../../features/health/models/health_status.dart';
import '../../providers/auth/auth_controller.dart';
import '../../providers/auth/auth_state.dart';
import '../../providers/di_providers.dart';
import '../../providers/home/main_tab_provider.dart';
import '../../widgets/common/navigation/app_bottom_nav_bar.dart';
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
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: currentTab.index,
        onTap: (index) => ref.read(mainTabProvider.notifier).state = MainTab.values[index],
        items: [
          for (final tab in MainTab.values)
            AppBottomNavBarItem(iconAsset: tab.iconAsset, label: tab.label),
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
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
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
  }

  @override
  Widget build(BuildContext context) {
    final myClubs = ref.watch(myClubsProvider);

    return Stack(
      children: [
        Column(
          children: [
            if (_isSearching)
              ClubSearchBar(
                controller: _searchController,
                onBack: _stopSearch,
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            else
              HomeAppBar(onSearchTap: _startSearch),
            Expanded(
              child: myClubs.when(
                data: (clubs) => _isSearching
                    ? _ClubSearchResultsView(clubs: clubs, query: _searchQuery)
                    : _ClubListView(
                        clubs: clubs,
                        scrollController: _scrollController,
                        onLongPressClub: _handleClubLongPress,
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('동아리 목록을 불러오지 못했어요: $error')),
              ),
            ),
          ],
        ),
        if (!_isSearching)
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
/// 않고(Figma 목업 상태), 검색어가 있는데 일치하는 동아리가 없으면 안내
/// 문구를 보여준다. 동아리 "이름"만 기준으로 부분 일치(대소문자 무시)한다.
class _ClubSearchResultsView extends StatelessWidget {
  const _ClubSearchResultsView({required this.clubs, required this.query});

  final List<ClubModel> clubs;
  final String query;

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

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      children: [for (final club in results) ClubListItem(club: club)],
    );
  }
}

class _ClubListView extends StatelessWidget {
  const _ClubListView({required this.clubs, required this.scrollController, required this.onLongPressClub});

  final List<ClubModel> clubs;
  final ScrollController scrollController;
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
            ClubListItem(club: club, onLongPress: (anchor) => onLongPressClub(club, anchor)),
        ],
        const ClubSectionHeader(title: '전체'),
        for (final club in clubs)
          ClubListItem(club: club, onLongPress: (anchor) => onLongPressClub(club, anchor)),
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
