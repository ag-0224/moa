import '../../../core/error_handling/result.dart';
import '../models/user_model.dart';

abstract interface class UserRepository {
  Future<Result<UserModel>> getMyInfo();

  Future<Result<UserModel>> completeProfile({
    required String name,
    required String nickname,
    required String major,
    required String studentId,
  });
}
