import '../../../core/error_handling/result.dart';
import '../../../core/storage/token_storage.dart';
import '../../user/models/user_model.dart';
import '../data_source/auth_api_data_source.dart';
import '../data_source/firebase_auth_data_source.dart';
import 'auth_repository.dart';
import 'entities/auth_provider_type.dart';

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
      if (idToken == null) {
        throw Exception('Firebase ID Token을 가져오지 못했습니다.');
      }

      // 주의: 여기서 실패하면(백엔드 다운/네트워크 오류 등) 절대 임의의 토큰을 만들어
      // 성공으로 처리하지 않는다. 이 저장소에는 백엔드가 직접 발급한 진짜 JWT만
      // 저장해야 하는데, 가짜 토큰을 저장하면 앱을 다시 켤 때 GET /users/me가 401로
      // 실패해 로그인이 유지되지 않는 버그가 생긴다.
      final loginResponse = await _authApiDataSource.login(idToken);
      await _tokenStorage.save(loginResponse.accessToken);

      return Result.success(loginResponse.user);
    } catch (error) {
      return Result.failure(error);
    }
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
