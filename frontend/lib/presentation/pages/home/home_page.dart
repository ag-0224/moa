import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/health/models/health_status.dart';
import '../../providers/auth/auth_controller.dart';
import '../../providers/auth/auth_state.dart';
import '../../providers/di_providers.dart';

/// docs/USER_FLOW.md의 '메인 홈 Screen'.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MOA'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text('안녕하세요, ${user.name}님', style: Theme.of(context).textTheme.titleLarge),
              Text(user.email),
              const SizedBox(height: 24),
            ],
            Text('서버 상태', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            const _HealthStatusView(),
          ],
        ),
      ),
    );
  }
}

class _HealthStatusView extends ConsumerWidget {
  const _HealthStatusView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkHealth = ref.watch(checkHealthUseCaseProvider);

    return FutureBuilder<HealthStatus>(
      future: checkHealth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('확인 중...');
        }
        if (snapshot.hasError) {
          return Text(
            '서버에 연결할 수 없습니다: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }
        final health = snapshot.data!;
        return Text('${health.status} · ${health.timestamp}');
      },
    );
  }
}
