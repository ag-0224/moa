import 'package:flutter/material.dart';

/// 동아리 목록 아이템을 꾹 눌렀을 때(long press) 뜨는 "즐겨찾기 추가/삭제"
/// 팝업. 화면 전체를 어둡게 깔고(barrier), 꾹 누른 위치 근처에 알약 모양
/// 버튼 하나를 띄운다. 버튼을 누르면 true를 반환하고(호출한 쪽에서 실제
/// 즐겨찾기 토글을 수행), 어두운 바깥 영역을 누르면 아무 동작 없이 닫힌다
/// (null 반환).
Future<bool?> showFavoriteActionSheet({
  required BuildContext context,
  Offset? anchor,
  required bool isFavorite,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '즐겨찾기 메뉴 닫기',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) {
      const horizontalMargin = 24.0;

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: horizontalMargin),
          child: _FavoriteActionPill(
            isFavorite: isFavorite,
            onTap: () => Navigator.of(context).pop(true),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

class _FavoriteActionPill extends StatelessWidget {
  const _FavoriteActionPill({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  static const double _height = 52;
  static const Color _backgroundColor = Color(0xFFEDEDED);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: _height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isFavorite ? Icons.star : Icons.star_border, size: 18, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                isFavorite ? '즐겨찾기 삭제하기' : '즐겨찾기 추가하기',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
