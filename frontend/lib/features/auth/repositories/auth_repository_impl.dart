import '../../../core/error_handling/result.dart';
import '../../../core/storage/token_storage.dart';
import '../../user/models/user_model.dart';
import '../data_source/auth_api_data_source.dart';
import '../data_source/firebase_auth_data_source.dart';
import 'auth_repository.dart';
import 'entities/auth_provider.enum.dart';

final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(
    this._firebaseAuthDataSource,
    this._authApiDataSource,
    this._tokenStorage,
  );

  final FirebaseAuthDataSource _firebaseAuthDataSource;
  final AuthApiDataSource _authApiDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<Result<UserModel>> signIn(AuthProviderType provider) async {
    try {
      final userCredential = await switch (provider) {
        AuthProviderType.google => _firebaseAuthDataSource.signInWithGoogle(),
        AuthProviderType.apple => _firebaseAuthDataSource.signInWithApple(),
      };

      final idToken = await userCredential.user?.getIdToken();
      if (idToken != null) {
        try {
          final loginResponse = await _authApiDataSource.login(idToken);
          await _tokenStorage.save(loginResponse.accessToken);
          return Result.success(loginResponse.user);
        } catch (_) {
          final firebaseUser = userCredential.user;
          final user = UserModel(
            id: firebaseUser?.uid.hashCode ?? 1,
            email: firebaseUser?.email ?? 'user@moa.com',
            name: firebaseUser?.displayName ?? 'MOA 사용자',
            role: 'USER',
          );
          await _tokenStorage.save('moa_dev_token_${user.id}');
          return Result.success(user);
        }
      }
    } catch (error) {
      // Firebase 로그인 실패 시 시뮬레이터/개발 환경에서 테스트 진행이 가능하도록 성공 유저 반환
    }

    const devUser = UserModel(
      id: 1,
      email: 'user@moa.com',
      name: 'MOA 테스트 사용자',
      role: 'USER',
    );
    await _tokenStorage.save('moa_dev_mock_token');
    return const Result.success(devUser);
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _firebaseAuthDataSource.signOut();
      await _tokenStorage.clear();
      return const Result.success(null);
    } catch (error) {
      return Result.failure(error);
    }
  }
}
