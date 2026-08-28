import 'package:dio/dio.dart';

import '../../../app/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../models/user_model.dart';

/// openapi.yaml GET /users/me 계약과 매핑된다.
abstract interface class UserApiDataSource {
  Future<UserModel> getMyInfo();
}

final class UserApiDataSourceImpl implements UserApiDataSource {
  UserApiDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<UserModel> getMyInfo() async {
    try {
      final response = await _apiClient.dio.get<Map<String, dynamic>>('/users/me');
      return _parse(response.data);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  UserModel _parse(Map<String, dynamic>? body) {
    if (body == null || body['success'] != true) {
      throw ApiException.fromJson(_errorOf(body));
    }
    return UserModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Object _mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['error'] != null) {
      return ApiException.fromJson(data['error'] as Map<String, dynamic>);
    }
    return e;
  }

  Map<String, dynamic> _errorOf(Map<String, dynamic>? body) {
    return (body?['error'] as Map<String, dynamic>?) ??
        {'code': 'UNKNOWN_ERROR', 'message': '알 수 없는 오류가 발생했습니다.'};
  }
}
