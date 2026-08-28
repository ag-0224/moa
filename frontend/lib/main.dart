import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/firebase/firebase_options.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 전역 에러 핸들러 설정: 비동기 및 UI 에러로 인해 앱이 예기치 않게 종료되는 것을 방지
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter UI 에러: ${details.exception}\n${details.stack}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('비동기 플랫폼 에러 (앱 강제 종료 방지): $error\n$stack');
    return true; // true 반환 시 앱 강제 종료 방지
  };

  // Firebase 프로젝트가 아직 설정되지 않은 환경에서도 앱이 즉시 죽지 않도록 안전하게 초기화
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (error, stackTrace) {
    debugPrint('Firebase 초기화 경고: $error\n$stackTrace');
  }

  runApp(const ProviderScope(child: MoaApp()));
}
