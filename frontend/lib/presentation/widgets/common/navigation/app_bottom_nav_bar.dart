import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// MOA 전역에서 쓰는 하단 탭 바.
///
/// Figma(node-id 3073-49, 하단 바 서브노드 3094-470) 스펙:
/// - 글자 라벨 없이 아이콘 3개만 있다(라벨은 화면에는 안 그리고 Semantics
///   접근성 라벨로만 쓴다).
/// - 바 전체가 회색(#D9D9D9) 한 덩어리이고, 화면 좌우 끝까지 꽉 채운다(가운데
///   구분선이나 흰 배경 없음). 3등분된 영역에 아이콘이 하나씩 가운데 정렬.
/// - 바의 좌우 끝 모서리만 위쪽으로 32px 둥글고 가운데는 각짐 — 세 영역이
///   이어 붙어 있으므로 바 전체 Container에 topLeft/topRight만 32 반지름을
///   주면 된다.
/// - 아이콘은 majesticons 세트 SVG(assets/icons/, core/constants/assets.dart)를
///   28x28로 그린다.
///
/// 홈 인디케이터가 있는 기기(아이폰 등)에서 하단 세이프에어리아를 64px
/// 높이 "안쪽"에서 SafeArea로 줄이면 아이콘 줄이 찌그러져 보이므로, 세이프
/// 에어리아만큼 높이를 더 늘리고 그 여백을 아이콘 줄 아래에 패딩으로 둬서
/// 회색 배경은 화면 맨 아래까지, 아이콘은 정확히 64px 안에서 가운데 정렬되게
/// 한다.
class AppBottomNavBarItem {
  const AppBottomNavBarItem({required this.iconAsset, required this.selectedIconAsset, required this.label});

  final String iconAsset;

  /// 이 탭이 선택된 상태일 때 대신 그릴 아이콘(보통 채워진 모양). 선택 여부에
  /// 따라 다른 아이콘을 쓰지 않는 탭은 iconAsset과 같은 값을 넘기면 된다.
  final String selectedIconAsset;

  /// 화면에 텍스트로 표시하지는 않지만(디자인에 라벨이 없음), 스크린리더용
  /// Semantics 라벨과 툴팁으로 쓴다.
  final String label;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.items, required this.currentIndex, required this.onTap});

  final List<AppBottomNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double contentHeight = 64;
  static const double _cornerRadius = 32;
  static const Color _backgroundColor = Color(0xFFD9D9D9);
  static const double _iconSize = 28;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_cornerRadius),
        topRight: Radius.circular(_cornerRadius),
      ),
      child: Container(
        width: double.infinity,
        height: contentHeight + bottomInset,
        color: _backgroundColor,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == currentIndex,
                  label: items[i].label,
                  child: InkWell(
                    onTap: () => onTap(i),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Center(
                      child: SvgPicture.asset(
                        i == currentIndex ? items[i].selectedIconAsset : items[i].iconAsset,
                        width: _iconSize,
                        height: _iconSize,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
