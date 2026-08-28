import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/assets.dart';
import '../../../widgets/common/button/app_rounded_button.dart';

/// Figma 'moa ver 3.0' 로그인 화면(node-id 3334:1413)의 '구글로 계속하기' 버튼.
///
/// TechTalk의 GoogleSignInButton(presentation/pages/sign_in/widgets/)과 같은
/// 위치·역할이다. 다만 TechTalk는 로고를 버튼 왼쪽 끝에 고정(Stack+Positioned)하지만,
/// 이 디자인에서는 로고와 텍스트가 하나의 덩어리로 버튼 중앙에 배치되어 있어
/// Row + mainAxisAlignment.center로 구현했다. 버튼 모양(둥근 모서리 16, 높이 60,
/// 로딩 상태)은 AppRoundedButton(공통 위젯)이 담당한다.
class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
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
      loadingColor: Colors.black,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      borderColor: const Color(0xFF31C1FF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(Assets.iconsGoogleLogo, width: 24, height: 24),
          const SizedBox(width: 12),
          const Text(
            '구글로 계속하기',
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
