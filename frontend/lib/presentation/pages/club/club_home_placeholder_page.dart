import 'package:flutter/material.dart';

import '../../../features/club/models/club_model.dart';

/// 이미 가입한 동아리를 눌렀을 때 이동하는 임시 화면.
///
/// 아직 MOA에는 동아리 전용 홈/공간 화면(게시판, 공지, 멤버 목록 등)이 없어서
/// 우선 이름/대표/소개 정도만 보여주는 자리표시자로 만들어뒀다. 나중에 실제
/// 동아리 홈 화면이 생기면 home_page.dart의 onTap이 이 위젯을 부르는 자리
/// 하나만 그걸로 바꾸면 된다.
class ClubHomePlaceholderPage extends StatelessWidget {
  const ClubHomePlaceholderPage({super.key, required this.club});

  final ClubModel club;

  static const Color _grayText = Color(0xFF8B8B8B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(club.name),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction, size: 48, color: _grayText),
              const SizedBox(height: 16),
              Text(
                '${club.name} 전용 화면은 아직 준비 중이에요.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                '대표: ${club.leaderName} · ${club.category} · ${club.memberCount}명',
                style: const TextStyle(fontSize: 14, color: _grayText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
