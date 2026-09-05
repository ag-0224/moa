import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../environment/environment.enum.dart';
import '../environment/flavor.dart';
import '../../presentation/app.dart';

Future<void> main() async {
  Flavor.initialize(Environment.prod);
  await Flavor.setup();

  // PROD 환경 Firebase 프로젝트 (moa-app-2026-prod) 안전 초기화
  try {
    await Firebase.initializeApp(options: Flavor.env.firebaseOptions);
  } catch (error, stackTrace) {
    debugPrint('[PROD] Firebase 초기화 경고: $error\n$stackTrace');
  }

  runApp(const ProviderScope(child: MoaApp()));
}
