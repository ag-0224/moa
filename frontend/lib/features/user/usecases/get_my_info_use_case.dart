import '../../../core/error_handling/result.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class GetMyInfoUseCase {
  const GetMyInfoUseCase(this._userRepository);

  final UserRepository _userRepository;

  Future<Result<UserModel>> call() => _userRepository.getMyInfo();
}
