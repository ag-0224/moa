/// 환경 설정. 저장소 루트 .env.example의 FLUTTER_API_BASE_URL과 대응한다.
/// 빌드/실행 시 --dart-define=API_BASE_URL=https://... 로 덮어쓸 수 있다.
class Env {
  const Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );
}
