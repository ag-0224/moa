import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/repositories/entities/auth_provider.enum.dart';
import '../../providers/auth/auth_controller.dart';
import '../../providers/auth/auth_state.dart';

/// docs/USER_FLOW.md의 '로그인 / 회원가입 Screen'.
/// MOA는 이메일/비밀번호 가입을 지원하지 않으므로(ADR 002) 구글/애플 버튼만 제공한다.
class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('MOA', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('구글 또는 애플 계정으로 로그인하세요'),
              const SizedBox(height: 32),
              if (authState is AuthError) ...[
                Text(authState.message, style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 16),
              ],
              FilledButton.icon(
                onPressed: isLoading
                    ? null
                    : () => ref.read(authControllerProvider.notifier).signIn(AuthProviderType.google),
                icon: const Icon(Icons.login),
                label: const Text('구글로 로그인'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isLoading
                    ? null
                    : () => ref.read(authControllerProvider.notifier).signIn(AuthProviderType.apple),
                icon: const Icon(Icons.apple),
                label: const Text('애플로 로그인'),
              ),
              if (isLoading) ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
