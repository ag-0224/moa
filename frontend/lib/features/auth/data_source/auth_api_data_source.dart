import 'package:dio/dio.dart';

import '../../../app/network/api_client.dart';
import '../../../core/network/api_envelope.dart';
import '../models/login_response.dart';

/// openapi.yaml POST /auth/login 계약과 매핑된다.
abstract interface class AuthApiDataSource {
  Future<LoginResponse> login(String idToken);
}

final class AuthApiDataSourceImpl implements AuthApiDataSource {
  AuthApiDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<LoginResponse> login(String idToken) async {
    try {
      final response = await _apiClient.dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'idToken': idToken},
      );
      return ApiEnvelope.unwrap(response.data, LoginResponse.fromJson);
    } on DioException catch (e) {
      throw ApiEnvelope.mapError(e);
    }
  }
}
