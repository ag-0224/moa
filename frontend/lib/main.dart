import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/firebase/firebase_options.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 프로젝트가 아직 설정되지 않은 환경(app/firebase/firebase_options.dart가
  // placeholder인 상태)에서도 앱이 즉시 죽지 않도록 초기화 실패를 흡수한다.
  // 설정 방법은 frontend/README.md 참고. 초기화가 안 됐다면 로그인 버튼을 눌렀을 때
  // 에러 상태로 안내된다.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (error, stackTrace) {
    debugPrint('Firebase 초기화 실패: $error\n$stackTrace');
  }

  runApp(const ProviderScope(child: MoaApp()));
}
