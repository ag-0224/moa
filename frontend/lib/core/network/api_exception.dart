/// docs/API_CONTRACT.md 표준 에러 응답({success:false, error:{code,message,details}})의
/// error 필드와 매핑되는 예외.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.details = const [],
  });

  final String code;
  final String message;
  final List<String> details;

  factory ApiException.fromJson(Map<String, dynamic> json) {
    return ApiException(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? '알 수 없는 오류가 발생했습니다.',
      details: (json['details'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  @override
  String toString() => 'ApiException($code): $message';
}
