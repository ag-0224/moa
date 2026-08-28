import 'package:flutter/material.dart';

/// Figma 'moa ver 3.0' 로그인 화면(node-id 3334:1413) 프레임 자체에는 애플
/// 버튼이 없지만, 요청에 따라 구글 버튼과 같은 스타일(둥근 모서리 16, 높이
/// 60)로 위쪽에 추가한 애플 로그인 버튼이다.
///
/// TechTalk의 AppleSignInButton(presentation/pages/sign_in/widgets/)과 같은
/// 위치·역할이다. TechTalk는 애플 로고를 font_awesome_flutter 패키지의
/// FaIcon(FontAwesomeIcons.apple)으로 그리는데, TechTalk assets 폴더에는 애플
/// 로고 svg가 없고(구글 로고만 assets/icons/google_logo.svg로 존재) MOA에
/// 이 아이콘 하나만을 위해 새 의존성을 추가하고 싶지 않아 Flutter Material
/// Icons에 내장된 Icons.apple을 대신 사용했다.
class AppleSignInButton extends StatelessWidget {
  const AppleSignInButton({
    super.key,
    required this.onTap,
    this.isLoading = false,
  });

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: FilledButton(
        onPressed: isLoading ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF09090B),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.apple, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Apple로 계속하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
