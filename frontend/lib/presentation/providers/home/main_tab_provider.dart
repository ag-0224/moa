import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 메인 페이지 하단 탭. TechTalk(MainNavigationTab, presentation/providers/
/// main_bottom_navigation_provider.dart)의 "탭 enum + 탭 상태 provider" 구조를
/// 참고했다. 다만 MOA는 build_runner 코드 생성을 쓰지 않기로 했으므로(문서:
/// flutter_riverpod, codegen 없음) @riverpod 대신 평범한 StateProvider로 만든다.
///
/// 아이콘: Figma(node-id 3073-49, 하단 바 3094-470)는 majesticons 아이콘
/// 세트(analytics-line, user-line)와 커스텀 홈 아이콘을 쓰는데, 이 세션에서는
/// - 클라우드/로컬 브릿지 양쪽 모두 figma.com 에셋 다운로드 URL에 네트워크
///   접근이 막혀 있고,
/// - Figma MCP 툴 호출 횟수(Starter 플랜)도 모두 소진돼서
/// 실제 SVG를 받아오지 못했다. 그래서 지금은 모양이 가장 비슷한 Material
/// 아이콘(집 모양/막대그래프/사람)으로 임시 대체해뒀다. 나중에 Figma에서 직접
/// SVG를 내보내 assets/icons/에 추가해주면 SvgPicture.asset으로 교체할 수
/// 있도록 해뒀다.
enum MainTab {
  home(label: '홈', icon: Icons.home),
  stats(label: '통계', icon: Icons.bar_chart_rounded),
  myPage(label: '마이페이지', icon: Icons.person_outline);

  const MainTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

final mainTabProvider = StateProvider<MainTab>((ref) => MainTab.home);
