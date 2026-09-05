import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase 프로젝트 (moa-app-2026-prod) PROD 전용 DefaultFirebaseOptions
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
    apiKey: 'AIzaSyAkN2ChZa7LMNFd9UwAPFFZKznJ8hyeXs4',
    appId: '1:271473387630:web:36fee1ca2059cd25905e7f',
    messagingSenderId: '271473387630',
    projectId: 'moa-app-2026-prod',
    authDomain: 'moa-app-2026-prod.firebaseapp.com',
    storageBucket: 'moa-app-2026-prod.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDraIS6wWI3PEkaLr6c-TdiB1xOiVzc05Y',
    appId: '1:271473387630:android:4d9498364baf597b905e7f',
    messagingSenderId: '271473387630',
    projectId: 'moa-app-2026-prod',
    storageBucket: 'moa-app-2026-prod.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAgoN5ACFrURfLjh4z1DTxmP6aR6GVpxwo',
    appId: '1:271473387630:ios:684a28418f14f4b5905e7f',
    messagingSenderId: '271473387630',
    projectId: 'moa-app-2026-prod',
    storageBucket: 'moa-app-2026-prod.firebasestorage.app',
    iosBundleId: 'com.moa.moa.prod',
  );
}
