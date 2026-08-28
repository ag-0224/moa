import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/assets.dart';

/// 앱 시작 시 로그인 상태(AuthController._restoreSession)를 확인하는 동안
/// 보여주는 스플래시 화면.
///
/// Figma 'moa ver 3.0' 파일의 '최초 화면 (splash)' 프레임(흰 배경 + 중앙에
/// 200x200 로고)을 그대로 옮겼다. TechTalk의 SplashPage(presentation/pages/splash/)와
/// 같은 위치·역할이지만, 로그인 상태에 따른 화면 전환(TechTalk의 SplashEvent가
/// 하던 라우팅)은 MOA에서는 이미 presentation/app.dart의 AuthState 분기가
/// 담당하고 있어 이 위젯은 순수하게 화면만 그린다.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 200,
          height: 200,
          child: SvgPicture.asset(Assets.logo),
        ),
      ),
    );
  }
}
