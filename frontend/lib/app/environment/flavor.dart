import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'environment.enum.dart';

class Flavor {
  Flavor._();

  static final Flavor _instance = Flavor._();
  static late Environment _env;
  static FirebaseApp? _firebaseApp;

  static Flavor get instance => _instance;
  static Environment get env => _env;
  static FirebaseApp get firebaseApp => _firebaseApp ?? Firebase.app();

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

    final app = await initializeFirebase();
    if (app != null) {
      _firebaseApp = app;
    }

    debugPrint('[Flavor] Application initialized with environment: ${_env.type}');
  }

  /// 환경별(DEV/PROD) Firebase 프로젝트 옵션을 안전하게 바인딩합니다.
  static Future<FirebaseApp?> initializeFirebase() async {
    final targetOptions = _env.firebaseOptions;

    // 1. 이미 동일한 projectId를 가진 앱이 초기화되어 있다면 그 앱을 사용
    for (final app in Firebase.apps) {
      if (app.options.projectId == targetOptions.projectId) {
        return app;
      }
    }

    // 2. 이미 존재하는 default 앱의 projectId가 다르면 네임드 앱으로 생성
    try {
      if (Firebase.apps.isEmpty) {
        return await Firebase.initializeApp(options: targetOptions);
      } else {
        return await Firebase.initializeApp(
          name: _env.type,
          options: targetOptions,
        );
      }
    } catch (error) {
      debugPrint('[${_env.type}] FirebaseApp 초기화 경고: $error');
      if (Firebase.apps.any((app) => app.name == _env.type)) {
        return Firebase.app(_env.type);
      }
      if (Firebase.apps.isNotEmpty) {
        return Firebase.app();
      }
      return null;
    }
  }
}
