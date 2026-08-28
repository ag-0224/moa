import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase 프로젝트 (moa-app-2026) 전용 DefaultFirebaseOptions 구성
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
        return android; // Safe fallback for other platforms to prevent app crashes
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyMOA_APP_2026_FIREBASE_API_KEY_VAL',
    appId: '1:1084295837261:web:moa2026appbundleid001',
    messagingSenderId: '1084295837261',
    projectId: 'moa-app-2026',
    authDomain: 'moa-app-2026.firebaseapp.com',
    storageBucket: 'moa-app-2026.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyMOA_APP_2026_FIREBASE_API_KEY_VAL',
    appId: '1:1084295837261:android:moa2026appbundleid001',
    messagingSenderId: '1084295837261',
    projectId: 'moa-app-2026',
    storageBucket: 'moa-app-2026.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyMOA_APP_2026_FIREBASE_API_KEY_VAL',
    appId: '1:1084295837261:ios:moa2026appbundleid001',
    messagingSenderId: '1084295837261',
    projectId: 'moa-app-2026',
    storageBucket: 'moa-app-2026.appspot.com',
    iosBundleId: 'com.moa.app',
  );
}
