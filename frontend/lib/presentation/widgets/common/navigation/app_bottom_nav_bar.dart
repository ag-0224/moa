import 'package:flutter/material.dart';

/// MOA 전역에서 쓰는 하단 탭 바.
///
/// Figma(node-id 3073-49, 하단 바 서브노드 3094-470)를 다시 확인해보니 실제
/// 디자인은 다음과 같았다(이전 구현이 여기서 벗어나 있었다):
/// - 글자 라벨이 없다. 아이콘 3개만 있다.
/// - 배경이 흰색+구분선이 아니라, 바 전체가 회색(#D9D9D9) 한 덩어리다.
/// - 바의 좌우 끝 모서리만 위쪽으로 32px 둥글고(왼쪽 세그먼트의 top-left,
///   오른쪽 세그먼트의 top-right), 가운데는 각지다 — 세 세그먼트가 이어 붙어
///   있으므로 바 전체 Container에 topLeft/topRight만 32 반지름을 주면 된다.
/// - 아이콘은 28x28, 3등분된 영역 안에서 각각 가운데 정렬.
///
/// 특정 탭 enum에 묶이지 않도록 아이콘 목록을 밖에서 받는 형태로 만들어서,
/// presentation/widgets/common/ 아래 다른 공통 위젯(AppRoundedButton,
/// AppTextField)들과 같은 자리에 둔다.
class AppBottomNavBarItem {
  const AppBottomNavBarItem({required this.icon, required this.label});

  final IconData icon;

  /// 화면에 텍스트로 표시하지는 않지만(디자인에 라벨이 없음), 스크린리더용
  /// Semantics 라벨과 툴팁으로 쓴다.
  final String label;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.items, required this.currentIndex, required this.onTap});

  final List<AppBottomNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double height = 64;
  static const double _cornerRadius = 32;
  static const Color _backgroundColor = Color(0xFFD9D9D9);
  static const Color _iconColor = Colors.black;
  static const double _iconSize = 28;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_cornerRadius),
        topRight: Radius.circular(_cornerRadius),
      ),
      child: Container(
        height: height,
        color: _backgroundColor,
        child: SafeArea(
          top: false,
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
                      child: Center(
                        child: Icon(items[i].icon, size: _iconSize, color: _iconColor),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
