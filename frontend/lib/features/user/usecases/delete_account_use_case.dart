import '../../../core/error_handling/result.dart';
import '../repositories/user_repository.dart';

/// 마이페이지('내 정보')의 '회원 탈퇴' 버튼이 호출하는 유스케이스.
class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._userRepository);

  final UserRepository _userRepository;

  Future<Result<void>> call() => _userRepository.deleteAccount();
}
