import '../../../core/error_handling/result.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

/// 회원가입 화면('회원 정보 입력')의 '작성 완료' 버튼이 호출하는 유스케이스.
class CompleteProfileUseCase {
  const CompleteProfileUseCase(this._userRepository);

  final UserRepository _userRepository;

  Future<Result<UserModel>> call({
    required String name,
    required String nickname,
    required String major,
    required String studentId,
  }) {
    return _userRepository.completeProfile(
      name: name,
      nickname: nickname,
      major: major,
      studentId: studentId,
    );
  }
}
