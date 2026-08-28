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
      if (idToken == null) {
        throw Exception('Firebase ID Token을 가져오지 못했습니다.');
      }

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
