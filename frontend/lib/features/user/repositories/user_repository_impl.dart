import '../../../core/error_handling/result.dart';
import '../data_source/user_api_data_source.dart';
import '../models/user_model.dart';
import 'user_repository.dart';

final class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._userApiDataSource);

  final UserApiDataSource _userApiDataSource;

  @override
  Future<Result<UserModel>> getMyInfo() async {
    try {
      final user = await _userApiDataSource.getMyInfo();
      return Result.success(user);
    } catch (error) {
      return Result.failure(error);
    }
  }
}
