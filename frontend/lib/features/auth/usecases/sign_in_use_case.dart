import '../../../core/error_handling/result.dart';
import '../../user/models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/entities/auth_provider_type.dart';

class SignInUseCase {
  const SignInUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Result<UserModel>> call(AuthProviderType provider) {
    return _authRepository.signIn(provider);
  }
}
