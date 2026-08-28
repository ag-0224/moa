import '../../../core/error_handling/result.dart';
import '../../user/models/user_model.dart';
import 'entities/auth_provider.enum.dart';

abstract interface class AuthRepository {
  ///
  /// [provider]로 Firebase 로그인 후, 발급받은 ID Token을 MOA 백엔드에 전달해
  /// 세션(액세스 토큰)을 연다.
  ///
  Future<Result<UserModel>> signIn(AuthProviderType provider);

  ///
  /// Firebase 로그아웃 + 저장된 MOA 액세스 토큰 삭제.
  ///
  Future<Result<void>> signOut();
}
