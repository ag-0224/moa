import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/assets.dart';
import '../../../features/auth/repositories/entities/auth_provider_type.dart';
import '../../providers/auth/auth_controller.dart';
import '../../providers/auth/auth_state.dart';
import 'widgets/apple_sign_in_button.dart';
import 'widgets/google_sign_in_button.dart';

/// docs/USER_FLOW.md의 '로그인 / 회원가입 Screen'.
/// MOA는 이메일/비밀번호 가입을 지원하지 않으므로(ADR 002) 구글/애플 버튼만 제공한다.
///
/// Figma 'moa ver 3.0' 로그인 화면(node-id 3334:1413)을 참고했다: 중앙에
/// 로고 + 타이틀 + 설명 문구, 하단에 로그인 버튼들. 원본 디자인에는 구글
/// 버튼만 있었지만 애플 버튼을 그 위에 추가로 배치했다.
class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              SizedBox(
                width: 200,
                height: 200,
                child: SvgPicture.asset(Assets.logo),
              ),
              const SizedBox(height: 24),
              const Text(
                '함께하는 스터디',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.8,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '스터디를 만들고 여러분의 목표를 달성해보세요.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFFA7A7A7)),
              ),
              const Spacer(flex: 4),
              if (authState is AuthError) ...[
                Text(
                  authState.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
              ],
              AppleSignInButton(
                isLoading: isLoading,
                onTap: () =>
                    ref.read(authControllerProvider.notifier).signIn(AuthProviderType.apple),
              ),
              const SizedBox(height: 12),
              GoogleSignInButton(
                isLoading: isLoading,
                onTap: () =>
                    ref.read(authControllerProvider.notifier).signIn(AuthProviderType.google),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 24,
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
