import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 메인 페이지 하단 탭. TechTalk(MainNavigationTab, presentation/providers/
/// main_bottom_navigation_provider.dart)의 "탭 enum + 탭 상태 provider" 구조를
/// 참고했다. 다만 MOA는 build_runner 코드 생성을 쓰지 않기로 했으므로(문서:
/// flutter_riverpod, codegen 없음) @riverpod 대신 평범한 StateProvider로 만든다.
enum MainTab {
  home(label: '홈', icon: Icons.home_outlined, selectedIcon: Icons.home),
  stats(label: '통계', icon: Icons.bar_chart_outlined, selectedIcon: Icons.bar_chart),
  myPage(label: '마이페이지', icon: Icons.person_outline, selectedIcon: Icons.person);

  const MainTab({required this.label, required this.icon, required this.selectedIcon});

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

final mainTabProvider = StateProvider<MainTab>((ref) => MainTab.home);
