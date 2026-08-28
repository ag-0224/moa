import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/assets.dart';

/// 메인 페이지 상단 고정 헤더(로고 + 검색 + 알림). Figma(node-id 3073-49)의
/// 최상단 바를 참고했다. 검색/알림 아이콘은 assets/icons/의 실제 SVG
/// (majesticons_search.svg, cil_bell.svg)를 쓴다. 별도 검색/알림 화면은
/// 아직 없어서 아이콘 탭은 onSearchTap/onNotificationTap 콜백으로 밖에서
/// 채워 넣도록 열어둔다.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key, this.onSearchTap, this.onNotificationTap});

  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;

  static const double height = 100;
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                'MOA',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF31C1FF)),
              ),
              const Spacer(),
              IconButton(
                onPressed: onSearchTap,
                icon: SvgPicture.asset(Assets.iconsSearch, width: _iconSize, height: _iconSize),
              ),
              IconButton(
                onPressed: onNotificationTap,
                icon: SvgPicture.asset(Assets.iconsBell, width: _iconSize, height: _iconSize),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
