import '../../../core/error_handling/result.dart';
import '../repositories/auth_repository.dart';

class SignOutUseCase {
  const SignOutUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<Result<void>> call() => _authRepository.signOut();
}
