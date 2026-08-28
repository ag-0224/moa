import 'package:dio/dio.dart';

import '../../../app/network/api_client.dart';
import '../../../core/network/api_envelope.dart';
import '../models/user_model.dart';

/// openapi.yaml GET/PATCH /users/me 계약과 매핑된다.
abstract interface class UserApiDataSource {
  Future<UserModel> getMyInfo();

  Future<UserModel> completeProfile({
    required String name,
    required String nickname,
    required String major,
    required String studentId,
  });
}

final class UserApiDataSourceImpl implements UserApiDataSource {
  UserApiDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<UserModel> getMyInfo() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/users/me');
      return ApiEnvelope.unwrap(response.data, UserModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }

  @override
  Future<UserModel> completeProfile({
    required String name,
    required String nickname,
    required String major,
    required String studentId,
  }) async {
    try {
      final response = await _apiClient.dio.patch<Map<String, dynamic>>('/users/me', data: {
        'name': name,
        'nickname': nickname,
        'major': major,
        'studentId': studentId,
      });
      return ApiEnvelope.unwrap(response.data, UserModel.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }
}
