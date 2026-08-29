import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moa/core/error_handling/result.dart';
import 'package:moa/features/auth/repositories/entities/auth_provider_type.dart';
import 'package:moa/features/auth/usecases/sign_in_use_case.dart';
import 'package:moa/features/auth/usecases/sign_out_use_case.dart';
import 'package:moa/features/user/models/user_model.dart';
import 'package:moa/features/user/usecases/delete_account_use_case.dart';
import 'package:moa/features/user/usecases/get_my_info_use_case.dart';
import 'package:moa/presentation/providers/auth/auth_controller.dart';
import 'package:moa/presentation/providers/auth/auth_state.dart';
import 'package:moa/presentation/providers/di_providers.dart';
import 'package:moa/presentation/providers/home/main_tab_provider.dart';

class _FakeSignInUseCase implements SignInUseCase {
  _FakeSignInUseCase(this.user);
  final UserModel user;

  @override
  Future<Result<UserModel>> call(AuthProviderType provider) async {
    return Result.success(user);
  }
}

class _FakeSignOutUseCase implements SignOutUseCase {
  @override
  Future<Result<void>> call() async {
    return const Result.success(null);
  }
}

class _FakeGetMyInfoUseCase implements GetMyInfoUseCase {
  _FakeGetMyInfoUseCase(this.result);
  final Result<UserModel> result;

  @override
  Future<Result<UserModel>> call() async {
    return result;
  }
}

class _FakeDeleteAccountUseCase implements DeleteAccountUseCase {
  @override
  Future<Result<void>> call() async {
    return const Result.success(null);
  }
}

void main() {
  const testUser = UserModel(
    id: 1,
    email: 'test@example.com',
    name: '테스트 유저',
    role: 'STUDENT',
    profileCompleted: true,
  );

  test('signOut() 호출 시 탭과 검색 상태가 초기화되고 AuthUnauthenticated로 전환된다', () async {
    final container = ProviderContainer(
      overrides: [
        signInUseCaseProvider.overrideWithValue(_FakeSignInUseCase(testUser)),
        signOutUseCaseProvider.overrideWithValue(_FakeSignOutUseCase()),
        getMyInfoUseCaseProvider.overrideWithValue(_FakeGetMyInfoUseCase(const Result.success(testUser))),
        deleteAccountUseCaseProvider.overrideWithValue(_FakeDeleteAccountUseCase()),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(authControllerProvider.notifier);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(authControllerProvider), isA<AuthAuthenticated>());

    // Change tab to stats
    container.read(mainTabProvider.notifier).state = MainTab.stats;
    container.read(isClubSearchingProvider.notifier).state = true;

    // Perform sign out
    await controller.signOut();

    expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
    expect(container.read(mainTabProvider), MainTab.home);
    expect(container.read(isClubSearchingProvider), false);
  });
}
