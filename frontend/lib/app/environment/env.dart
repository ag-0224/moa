import 'package:flutter/foundation.dart';

import 'environment.enum.dart';
import 'flavor.dart';

/// 환경 설정 클래스.
/// `Flavor.env`를 참조하며, 동적으로 선택된 Flavor의 설정값을 반환합니다.
class Env {
  const Env._();

  static String get apiBaseUrl {
    final url = Flavor.env.apiBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return url.replaceAll('localhost', '10.0.2.2');
    }
    return url;
  }

  static Environment get currentEnvironment => Flavor.env;
  static bool get isDev => Flavor.env == Environment.dev;
  static bool get isProd => Flavor.env == Environment.prod;
}
