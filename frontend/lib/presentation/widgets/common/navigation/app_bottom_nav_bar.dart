import 'package:flutter/material.dart';

/// MOA 전역에서 쓰는 하단 탭 바. 특정 탭 enum에 묶이지 않도록 아이콘/라벨
/// 목록을 밖에서 받는 형태로 만들어서, presentation/widgets/common/ 아래 다른
/// 공통 위젯(AppRoundedButton, AppTextField)들과 같은 자리에 둔다.
class AppBottomNavBarItem {
  const AppBottomNavBarItem({required this.icon, required this.selectedIcon, required this.label});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({super.key, required this.items, required this.currentIndex, required this.onTap});

  final List<AppBottomNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double height = 64;
  static const Color _selectedColor = Color(0xFF31C1FF);
  static const Color _unselectedColor = Color(0xFF8B8B8B);
  static const Color _borderColor = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        i == currentIndex ? items[i].selectedIcon : items[i].icon,
                        color: i == currentIndex ? _selectedColor : _unselectedColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontSize: 11,
                          color: i == currentIndex ? _selectedColor : _unselectedColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
