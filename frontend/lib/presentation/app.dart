import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/home/home_page.dart';
import 'pages/sign_in/sign_in_page.dart';
import 'pages/sign_up/sign_up_page.dart';
import 'pages/splash/splash_page.dart';
import 'providers/auth/auth_controller.dart';
import 'providers/auth/auth_state.dart';

class MoaApp extends ConsumerWidget {
  const MoaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'MOA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo, scaffoldBackgroundColor: Colors.white),
      home: switch (authState) {
        AuthInitial() || AuthLoading() => const SplashPage(),
        AuthAuthenticated() => const HomePage(),
        AuthNeedsSignUp(:final user) => SignUpPage(user: user),
        AuthUnauthenticated() || AuthError() => const SignInPage(),
      },
    );
  }
}
