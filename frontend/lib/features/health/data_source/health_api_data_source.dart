import '../../../app/network/api_client.dart';
import '../models/health_status.dart';

/// openapi.yaml GET /health 계약과 매핑된다.
/// 주의: /health는 {success, data, error} 표준 포맷이 정해지기 전에 만들어진 예외라
/// {status, timestamp}를 그대로 반환한다 (docs/API_CONTRACT.md 참고). 그래서 다른
/// features의 data source와 달리 success/error 봉투를 벗기지 않는다.
abstract interface class HealthApiDataSource {
  Future<HealthStatus> check();
}

final class HealthApiDataSourceImpl implements HealthApiDataSource {
  HealthApiDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<HealthStatus> check() async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>('/health');
    return HealthStatus.fromJson(response.data!);
  }
}
