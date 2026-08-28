import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase 프로젝트 (moa-app-2026-dev) 전용 DefaultFirebaseOptions 구성
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAMc6IVV8HWSudn7hXcog8zmuvRF27uSZA',
    appId: '1:535931109546:web:99a7ce7f4d1685f87790d3',
    messagingSenderId: '535931109546',
    projectId: 'moa-app-2026-dev',
    authDomain: 'moa-app-2026-dev.firebaseapp.com',
    storageBucket: 'moa-app-2026-dev.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC5BKGsh5xR03tyJ6SteeTxY0XM3vXMyQ8',
    appId: '1:535931109546:android:3ac6ebdfbcb4585d7790d3',
    messagingSenderId: '535931109546',
    projectId: 'moa-app-2026-dev',
    storageBucket: 'moa-app-2026-dev.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCIfaM-u7VZExP4x3n4-Z7jJmwt7GNUCY4',
    appId: '1:535931109546:ios:f57c735fd40f6ff37790d3',
    messagingSenderId: '535931109546',
    projectId: 'moa-app-2026-dev',
    storageBucket: 'moa-app-2026-dev.firebasestorage.app',
    iosBundleId: 'com.moa.app',
  );
}
