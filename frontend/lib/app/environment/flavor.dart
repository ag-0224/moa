import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'environment.enum.dart';

class Flavor {
  Flavor._();

  static final Flavor _instance = Flavor._();
  static late Environment _env;

  static Flavor get instance => _instance;
  static Environment get env => _env;

  static void initialize(Environment type) {
    _env = type;
  }

  /// [env]에 따라 애플리케이션 초기 설정을 진행합니다.
  static Future<void> setup() async {
    WidgetsFlutterBinding.ensureInitialized();

    // 전역 에러 핸들러 설정: 비동기 및 UI 에러로 인해 앱이 예기치 않게 종료되는 것을 방지
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('[${_env.type}] Flutter UI 에러: ${details.exception}\n${details.stack}');
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('[${_env.type}] 비동기 플랫폼 에러: $error\n$stack');
      return true;
    };

    debugPrint('[Flavor] Application initialized with environment: ${_env.type}');
  }
}
