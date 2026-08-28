import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/assets.dart';

/// 메인 페이지 상단 고정 헤더(로고 + 검색 + 알림). Figma(node-id 3073-49)의
/// 최상단 바를 참고했다.
///
/// - 로고는 텍스트가 아니라 assets/logo_with_name.svg(Figma 스펙 155x50,
///   "moarium" 워드마크 포함)를 그대로 쓰고, 위아래 25px씩 여백을 둔다
///   (25 + 50 + 25 = 헤더 높이 100과 정확히 맞아떨어진다).
/// - 검색/알림 아이콘은 assets/icons/의 실제 SVG(majesticons_search.svg,
///   cil_bell.svg)를 28x28로 쓰고, 두 아이콘 사이 간격은 28px이다. 정확한
///   간격을 맞추기 위해 자체 여백이 있는 IconButton 대신 GestureDetector +
///   고정폭 SizedBox로 구현한다.
///
/// 별도 검색/알림 화면은 아직 없어서 아이콘 탭은 onSearchTap/onNotificationTap
/// 콜백으로 밖에서 채워 넣도록 열어둔다.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.onSearchTap, this.onNotificationTap});

  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;

  static const double height = 100;
  static const double _logoWidth = 155;
  static const double _logoHeight = 50;
  static const double _logoVerticalMargin = 25;
  static const double _iconSize = 28;
  static const double _iconGap = 28;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: _logoVerticalMargin),
          child: Row(
            children: [
              SvgPicture.asset(Assets.logoWithName, width: _logoWidth, height: _logoHeight),
              const Spacer(),
              GestureDetector(
                onTap: onSearchTap,
                child: SvgPicture.asset(Assets.iconsSearch, width: _iconSize, height: _iconSize),
              ),
              const SizedBox(width: _iconGap),
              GestureDetector(
                onTap: onNotificationTap,
                child: SvgPicture.asset(Assets.iconsBell, width: _iconSize, height: _iconSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
