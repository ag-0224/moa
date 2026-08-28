/// openapi.yaml GET /health 응답 스키마와 매핑된다.
class HealthStatus {
  const HealthStatus({required this.status, required this.timestamp});

  final String status;
  final String timestamp;

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
    );
  }
}
