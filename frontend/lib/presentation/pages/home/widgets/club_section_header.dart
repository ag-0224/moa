import 'package:flutter/material.dart';

/// "즐겨찾기" / "전체" 같은 동아리 섹션 제목.
class ClubSectionHeader extends StatelessWidget {
  const ClubSectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black),
      ),
    );
  }
}
