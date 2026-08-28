import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/assets.dart';

/// 메인 페이지 하단 탭. TechTalk(MainNavigationTab, presentation/providers/
/// main_bottom_navigation_provider.dart)의 "탭 enum + 탭 상태 provider" 구조를
/// 참고했다. 다만 MOA는 build_runner 코드 생성을 쓰지 않기로 했으므로(문서:
/// flutter_riverpod, codegen 없음) @riverpod 대신 평범한 StateProvider로 만든다.
///
/// 아이콘은 Figma(node-id 3073-49, 하단 바 3094-470)의 majesticons 세트를
/// assets/icons/에 실제 SVG로 받아서 쓴다(core/constants/assets.dart 참고).
enum MainTab {
  home(label: '홈', iconAsset: Assets.iconsHome, selectedIconAsset: Assets.iconsHome),
  stats(
    label: '통계',
    iconAsset: Assets.iconsAnalytics,
    selectedIconAsset: Assets.iconsAnalyticsSelected,
  ),
  myPage(label: '마이페이지', iconAsset: Assets.iconsUser, selectedIconAsset: Assets.iconsUserSelected);

  const MainTab({required this.label, required this.iconAsset, required this.selectedIconAsset});

  final String label;
  final String iconAsset;

  /// 이 탭이 선택됐을 때 보여줄 아이콘(채워진 모양). 홈은 선택 여부와
  /// 상관없이 같은 아이콘을 쓴다(별도로 채워진 버전이 없음).
  final String selectedIconAsset;
}

final mainTabProvider = StateProvider<MainTab>((ref) => MainTab.home);

/// 홈 탭에서 동아리 검색 모드인지 여부. HomePage(하단 탭 바 표시 여부)와
/// _HomeFeedTab(검색창/검색 결과 표시 여부)이 함께 봐야 해서 위젯 트리
/// 상위(HomePage)와 하위(_HomeFeedTab)에 걸쳐 공유하는 상태로 뺐다.
final isClubSearchingProvider = StateProvider<bool>((ref) => false);
