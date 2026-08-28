import 'package:flutter/material.dart';

import '../../../../core/constants/assets.dart';
import '../../../../features/club/models/club_model.dart';

/// 동아리 목록의 한 행(썸네일 + 이름 + 카테고리 · 인원수).
///
/// - thumbnailUrl이 없으면(동아리 사진 미등록) Assets.clubDefaultThumbnail
///   기본 이미지를 대신 보여준다.
/// - 꾹 누르면(long press) onLongPress로 누른 화면 좌표(글로벌 좌표)를
///   넘긴다 — 즐겨찾기 추가/삭제 팝업(favorite_action_sheet.dart)을 그
///   위치 근처에 띄우는 데 쓴다.
class ClubListItem extends StatelessWidget {
  const ClubListItem({super.key, required this.club, this.onTap, this.onLongPress});

  final ClubModel club;
  final VoidCallback? onTap;
  final ValueChanged<Offset>? onLongPress;

  static const double _thumbnailSize = 60;
  static const Color _grayText = Color(0xFF8B8B8B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: onLongPress == null ? null : (details) => onLongPress!(details.globalPosition),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: _thumbnailSize,
                  height: _thumbnailSize,
                  child: club.thumbnailUrl != null
                      ? Image.network(club.thumbnailUrl!, fit: BoxFit.cover)
                      : Image.asset(Assets.clubDefaultThumbnail, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${club.category} · ${club.memberCount}명',
                      style: const TextStyle(fontSize: 13, color: _grayText),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _grayText),
            ],
          ),
        ),
      ),
    );
  }
}
