import 'package:flutter/material.dart';

import '../../../../features/club/models/club_model.dart';

/// 동아리 목록의 한 행(썸네일 + 이름 + 카테고리 · 인원수). 실제 썸네일 이미지
/// URL이 없을 때는 회색 placeholder 박스를 보여준다.
class ClubListItem extends StatelessWidget {
  const ClubListItem({super.key, required this.club, this.onTap});

  final ClubModel club;
  final VoidCallback? onTap;

  static const double _thumbnailSize = 60;
  static const Color _grayText = Color(0xFF8B8B8B);

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                    : Container(
                        color: const Color(0xFFF0F2F5),
                        child: const Icon(Icons.groups_outlined, color: _grayText),
                      ),
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
    );
  }
}
