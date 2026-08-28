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
  home(label: '홈', iconAsset: Assets.iconsHome),
  stats(label: '통계', iconAsset: Assets.iconsAnalytics),
  myPage(label: '마이페이지', iconAsset: Assets.iconsUser);

  const MainTab({required this.label, required this.iconAsset});

  final String label;
  final String iconAsset;
}

final mainTabProvider = StateProvider<MainTab>((ref) => MainTab.home);
