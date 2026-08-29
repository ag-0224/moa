import 'package:flutter/material.dart';

/// 스터디 내 "내 정보" 탭 자리표시자(마이페이지의 전역 "내 정보"와는 다르게,
/// 이 스터디 안에서의 내 출석/휴가/프로필을 보여줄 자리다). 이번 작업
/// 범위(출석현황 탭)에 포함되지 않아 비워둔다.
class StudyMyInfoPlaceholderTab extends StatelessWidget {
  const StudyMyInfoPlaceholderTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('스터디 내 정보 기능은 아직 준비중이에요.', style: TextStyle(color: Color(0xFF8B8B8B))),
    );
  }
}
