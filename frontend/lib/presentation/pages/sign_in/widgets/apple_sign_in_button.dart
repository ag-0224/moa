import 'package:flutter/material.dart';

import '../../../widgets/common/button/app_rounded_button.dart';

/// Figma 'moa ver 3.0' 로그인 화면(node-id 3334:1413) 프레임 자체에는 애플
/// 버튼이 없지만, 요청에 따라 구글 버튼과 같은 스타일(둥근 모서리 16, 높이
/// 60)로 위쪽에 추가한 애플 로그인 버튼이다.
///
/// TechTalk의 AppleSignInButton(presentation/pages/sign_in/widgets/)과 같은
/// 위치·역할이다. TechTalk는 애플 로고를 font_awesome_flutter 패키지의
/// FaIcon(FontAwesomeIcons.apple)으로 그리는데, TechTalk assets 폴더에는 애플
/// 로고 svg가 없고(구글 로고만 assets/icons/google_logo.svg로 존재) MOA에
/// 이 아이콘 하나만을 위해 새 의존성을 추가하고 싶지 않아 Flutter Material
/// Icons에 내장된 Icons.apple을 대신 사용했다. 버튼 모양은 GoogleSignInButton과
/// 마찬가지로 AppRoundedButton(공통 위젯)이 담당한다.
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
    return AppRoundedButton(
      onPressed: onTap,
      isLoading: isLoading,
      backgroundColor: const Color(0xFF09090B),
      foregroundColor: Colors.white,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.apple, size: 24),
          SizedBox(width: 12),
          Text(
            'Apple로 계속하기',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}
