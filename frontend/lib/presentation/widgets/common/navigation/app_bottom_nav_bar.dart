import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// MOA 전역에서 쓰는 하단 탭 바.
///
/// Figma(node-id 3073-49, 하단 바 서브노드 3094-470) 원안은 바 전체가
/// 회색(#D9D9D9) 한 덩어리였지만, 화면 배경(흰색)과 확 갈라져 보인다는
/// 피드백에 따라 배경을 화면과 같은 흰색에 가깝게 바꾸고, 구분이 아예 안
/// 되지는 않도록 아주 옅은 상단 선(hairline) 하나만 남겼다 — 이 앱의 다른
/// 곳(team_register_button.dart 등)처럼 그림자(elevation) 없는 flat한
/// 스타일을 그대로 유지하면서, 흰 배경 카드들(ClubListItem, HomeAppBar 등)
/// 사이에서 자연스럽게 이어지도록 한 것.
///
/// 나머지 스펙은 원안 그대로다:
/// - 글자 라벨 없이 아이콘 3개만 있다(라벨은 화면에는 안 그리고 Semantics
///   접근성 라벨로만 쓴다).
/// - 화면 좌우 끝까지 꽉 채운다(가운데 구분선 없음). 3등분된 영역에 아이콘이
///   하나씩 가운데 정렬.
/// - 바의 좌우 끝 모서리만 위쪽으로 32px 둥글고 가운데는 각짐 — 세 영역이
///   이어 붙어 있으므로 바 전체 Container에 topLeft/topRight만 32 반지름을
///   주면 된다.
/// - 아이콘은 majesticons 세트 SVG(assets/icons/, core/constants/assets.dart)를
///   28x28로 그린다.
///
/// 홈 인디케이터가 있는 기기(아이폰 등)에서 하단 세이프에어리아를 64px
/// 높이 "안쪽"에서 SafeArea로 줄이면 아이콘 줄이 찌그러져 보이므로, 세이프
/// 에어리아만큼 높이를 더 늘리고 그 여백을 아이콘 줄 아래에 패딩으로 둬서
/// 배경은 화면 맨 아래까지, 아이콘은 정확히 64px 안에서 가운데 정렬되게 한다.
/// 다만 기기가 보고하는 실제 세이프에어리아 값(아이폰은 보통 34)을 그대로
/// 쓰면 아이콘 줄 아래 여백만 유독 넓어 보인다는 피드백이 있어서,
/// [_maxBottomCushion]으로 여백의 최댓값을 낮춰서 쓴다 — 이 여백은 탭
/// 영역이 아니라 순수 시각적 쿠션이라(각 아이콘의 InkWell은 위쪽 아이콘
/// 줄 영역에만 걸려 있음) 줄여도 터치 영역에는 영향이 없다.
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

  /// 화면 배경(Colors.white)과 같은 색. 완전히 같은 색으로 맞춰 튀지 않게
  /// 하되, 바로 아래 옅은 선(_topBorderColor)으로 최소한의 구분만 남긴다.
  static const Color _backgroundColor = Colors.white;
  static const Color _topBorderColor = Color(0xFFEFEFEF);
  static const double _topBorderWidth = 1;
  static const double _iconSize = 28;

  /// 아이콘 줄 아래에 두는 세이프에어리아 여백의 최댓값. 기기가 보고하는
  /// 값(홈 인디케이터가 있는 아이폰은 보통 34)을 그대로 쓰면 아래 여백만
  /// 눈에 띄게 넓어 보여서, 홈 인디케이터를 가리지 않을 정도로만 줄였다.
  static const double _maxBottomCushion = 16;

  @override
  Widget build(BuildContext context) {
    final rawBottomInset = MediaQuery.of(context).padding.bottom;
    final bottomInset = rawBottomInset > _maxBottomCushion ? _maxBottomCushion : rawBottomInset;

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
        child: Column(
          children: [
            Container(height: _topBorderWidth, color: _topBorderColor),
            Expanded(
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
          ],
        ),
      ),
    );
  }
}
