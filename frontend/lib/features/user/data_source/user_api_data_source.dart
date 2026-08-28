import 'package:dio/dio.dart';

import '../../../app/network/api_client.dart';
import '../../../core/network/api_envelope.dart';
import '../models/user_model.dart';

/// openapi.yaml GET/PATCH/DELETE /users/me 계약과 매핑된다.
abstract interface class UserApiDataSource {
  Future<UserModel> getMyInfo();

  Future<UserModel> completeProfile({
    required String name,
    required String nickname,
    required String major,
    required String studentId,
  });

  /// 회원 탈퇴. 성공하면 서버에서 계정이 완전히 삭제된다.
  Future<void> deleteAccount();
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

  @override
  Future<void> deleteAccount() async {
    try {
      await _apiClient.dio.delete<Map<String, dynamic>>('/users/me');
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }
}
