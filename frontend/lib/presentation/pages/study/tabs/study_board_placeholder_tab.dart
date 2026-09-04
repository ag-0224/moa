import 'package:flutter/material.dart';

/// 게시판 탭 자리표시자. 이번 작업 범위(출석현황 탭)에 포함되지 않아
/// home_page.dart의 _StatsPlaceholderTab과 같은 패턴으로 비워둔다.
class StudyBoardPlaceholderTab extends StatelessWidget {
  const StudyBoardPlaceholderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('게시판 기능은 아직 준비중이에요.', style: TextStyle(color: Color(0xFF8B8B8B))),
    );
  }
}
