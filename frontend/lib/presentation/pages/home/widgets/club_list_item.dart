import 'package:flutter/material.dart';

import '../../../../core/constants/assets.dart';
import '../../../../features/club/models/club_model.dart';

/// 동아리 목록의 한 행(썸네일 + 이름 + 대표 이름·카테고리·인원수).
///
/// - thumbnailUrl이 없으면(동아리 사진 미등록) Assets.clubDefaultThumbnail
///   기본 이미지를 대신 보여준다.
/// - 대표 이름(leaderName)·카테고리·인원수를 한 줄에 같이 보여준다(로컬 개발용
///   더미데이터는 전부 대표 이름이 "박승찬", backend/src/main/resources/data.sql 참고).
/// - 글자 스펙(폰트 크기/굵기/줄간격/자간)은 Figma 값을 최대한 반영하되,
///   Flutter TextStyle이 표현 못 하는 부분(예: 퍼센트 단위 자간 → 폰트
///   크기에 비례한 절대값으로 환산)은 근사치로 구현했다.
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4, // Figma: -2.5% of 16
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${club.leaderName} · ${club.category} · ${club.memberCount}명',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 22 / 14, // Figma line-height 22
                        letterSpacing: -0.35, // Figma: -2.5% of 14
                        color: _grayText,
                      ),
                      overflow: TextOverflow.ellipsis,
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
