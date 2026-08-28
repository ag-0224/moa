import 'package:dio/dio.dart';

import '../../core/storage/token_storage.dart';
import '../environment/env.dart';

/// MOA 백엔드(openapi.yaml) 전용 Dio 클라이언트.
/// TokenStorage에 저장된 accessToken이 있으면 모든 요청에 Authorization 헤더를 자동으로 붙인다.
class ApiClient {
  ApiClient(this._tokenStorage)
      : dio = Dio(
          BaseOptions(
            baseUrl: Env.apiBaseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio dio;
  final TokenStorage _tokenStorage;
}
