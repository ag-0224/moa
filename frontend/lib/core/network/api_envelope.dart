import 'package:dio/dio.dart';

import 'api_exception.dart';

/// docs/API_CONTRACT.md 표준 응답 봉투({success, data, error})를 쓰는
/// data source들이 공통으로 사용하는 파싱/에러 매핑 로직.
///
/// 주의: GET /health는 이 봉투를 쓰지 않는 문서화된 예외라 이 헬퍼를 쓰지 않는다
/// (features/health/data_source/health_api_data_source.dart 참고).
class ApiEnvelope {
  const ApiEnvelope._();

  /// {success:true, data:{...}}에서 data를 꺼내 [fromJson]으로 변환한다.
  /// success가 아니거나 data가 없으면 [ApiException]을 던진다.
  static T unwrap<T>(
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (body == null || body['success'] != true) {
      throw ApiException.fromJson(_errorOf(body));
    }
    return fromJson(body['data'] as Map<String, dynamic>);
  }

  /// {success:true, data:[...]}에서 data를 꺼내 리스트의 각 원소를 [fromJson]으로
  /// 변환한다. GET /clubs, GET /clubs/me처럼 JSON 배열을 내려주는 응답에 쓴다.
  static List<T> unwrapList<T>(
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (body == null || body['success'] != true) {
      throw ApiException.fromJson(_errorOf(body));
    }
    final data = body['data'] as List<dynamic>;
    return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  /// [DioException]을 서버가 표준 에러 봉투로 응답한 경우 [ApiException]으로,
  /// 그 외(네트워크 오류 등 서버 응답 자체가 없는 경우)는 원본 그대로 반환한다.
  static Object mapError(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data['error'] != null) {
      return ApiException.fromJson(data['error'] as Map<String, dynamic>);
    }
    return e;
  }

  static Map<String, dynamic> _errorOf(Map<String, dynamic>? body) {
    return (body?['error'] as Map<String, dynamic>?) ??
        {'code': 'UNKNOWN_ERROR', 'message': '알 수 없는 오류가 발생했습니다.'};
  }
}
